import java.io.{BufferedWriter, File, FileWriter, StringWriter}
import java.nio.file.{Files, Paths}
import scala.xml.transform.{RewriteRule, RuleTransformer}
import scala.xml.{Elem, Node, NodeSeq, Text, XML}

object InvoiceTransformer {


  def transformFile(inputFile: File): String = {
    val invoiceXml = loadXml(inputFile)
    val invoiceInfo = InvoiceInfo(invoiceXml)
    val transformed = transformXml(invoiceXml, invoiceInfo)
    val sw = new StringWriter()
    val bw = new BufferedWriter(sw)
    write(transformed.head, bw)
    bw.close()
    sw.toString
  }

  def transformFile(inputFile: File, outputFile: File): File = {
    println(s"Transforming Invoice: ${inputFile.getName}")
    val invoiceXml = loadXml(inputFile)
    val invoiceInfo = InvoiceInfo(invoiceXml)
    val transformed = transformXml(invoiceXml, invoiceInfo)
    save(outputFile, transformed.head)
    outputFile
  }

  def loadXml(filePath: File): Elem =
    XML.loadFile(filePath)

  def write(contents:Node, writer: BufferedWriter): Unit = {
    writer.write("""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>""")
    writer.write(System.getProperty("line.separator"))
    XML.write(writer, contents, "utf-8", false, null)
    writer.close()
  }

  def save(file: File, contents: Node): Unit = {
    val bw = new BufferedWriter(new FileWriter(file))
    write(contents,bw)
  }


  def transformXml(invoice: Elem, invoiceInfo: InvoiceInfo) = {
    val rule1 = getRewriteRule("megrendeles", invoiceInfo.orderNumber)
    val rule2 = getRewriteRule("megrendelesdatum", invoiceInfo.date)
    val rule3 = getRewriteRule("szallitolevel", invoiceInfo.letterNumber)
    val rule4 = getRewriteRule("szallitoleveldatum", invoiceInfo.letterDate)
    val companyName = (invoice \ "fejlec" \ "elado" \ "nev").text
    val rule5 = getRewriteRule("szamlatulaj", companyName)
    val rule6 = getRewriteRule("banknev", "Országos Takarékpénztár és Kereskedelmi Bank")
    object rt1 extends RuleTransformer(rule5, rule6)
    val rule4Seller: RewriteRule = new RewriteRule {
      override def transform(n: Node): collection.Seq[Node] = n match {
        case elem: Elem if elem.label == "elado" => rt1(elem) //This rule uses another rule
        case other => other
      }
    }
    val deliveryNumRule = invoiceInfo.deliveryNumber.map(num => getAddRule("elado", <szallitoiazonosito>
      {num}
    </szallitoiazonosito>))

    val allRules = List(Some(rule1), Some(rule2), Some(rule3), Some(rule4), Some(rule4Seller), deliveryNumRule).flatten

    val transformed = new RuleTransformer(allRules*).transform(invoice)
    transformed
  }


  protected def getRewriteRule(matchOnLabel: String, newText: String): RewriteRule =
    new RewriteRule {
      override def transform(n: Node): collection.Seq[Node] = n match {
        case elem: Elem if elem.label == matchOnLabel =>
          Elem(elem.prefix, elem.label, elem.attributes, elem.scope, false, Text(newText))
        case other => other
      }
    }

  protected def getAddRule(label: String, newChild: Node): RewriteRule = {
    new RewriteRule {
      override def transform(n: Node) = n match {
        case n@Elem(prefix, `label`, attribs, scope, child@_*) =>
          //println("CCC: " + child.toList.map(a => a.text.toList.map(_.toInt.toHexString).mkString).mkString("\r\n"))
          val originals = child.toList.splitAt(16) //Every second line is a newline
          val newLine = originals._1(0)
          val allNodes = originals._1 ++ newLine ++ newChild ++ originals._2
          Elem(prefix, label, attribs, scope, false, allNodes*)
        case other => other
      }
    }
  }
}


case class InvoiceInfo(orderNumber: String, date: String, letterNumber: String, letterDate: String, deliveryNumber: Option[String])

object InvoiceInfo {
  // Information about the invoice is hidden in the comment field of the invoice, we have to extract those
  def apply(invoice: Elem): InvoiceInfo = {
    val comment = extractComment(invoice)
    val buyer = extractBuyer(invoice)
    val lines = comment.split("[\r\n]")
    val pattern = """Szállítószám:\s(\d+?)\s""".r
    val deliveryNumber = pattern.findFirstMatchIn(comment) match {
      case Some(x) => Some(x.group(1))
      case _ => if (buyer.toLowerCase.contains("tesco")) Some("20997040") else None
    }
    InvoiceInfo(valueParser(lines(0)), transformDates(valueParser(lines(1))), valueParser(lines(2)), transformDates(valueParser(lines(3))), deliveryNumber)
  }

  def transformDates(in: String): String = {
    val full = in.replaceAll("\\.", "- ").trim
    if (full.lastIndexOf("-") == full.length - 1) full.take(full.length - 1) else full
  }


  def extractComment(invoice: Elem) = {
    val comments = invoice \ "tetelek" \ "tetel" \ "megjegyzes"
    comments.toList.map(_.text).head
  }

  def extractBuyer(invoice: Elem): String = {
    val buyer = invoice \ "fejlec" \ "vevo" \ "nev"
    buyer.toList.map(_.text).head
  }


  def valueParser(line: String): String = {
    val idx = line.indexOf(":")
    line.substring(idx + 1).trim
  }
}

