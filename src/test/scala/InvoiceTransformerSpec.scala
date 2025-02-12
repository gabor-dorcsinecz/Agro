import InvoiceTransformer.*
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.*

import java.nio.file.{Files, Paths}

class InvoiceTransformerSpec extends AnyFunSuite with should.Matchers {

  test("Compare Generated String with the correct file") {
    val result = transformFile(Paths.get("src/test/resources/EInvoice.xml").toFile)
    val expectedResult = Files.readString(Paths.get("src/test/resources/EInvoice-Expected.Xml")) //, Charset.forName("ISO-8859-2"))
    expectedResult shouldBe result
  }
  
  //  "InvoiceInfo" should {
  //    "parse" in {
  //      val comment = """Megrendelés száma: 342590
  //        |Megrendelés kelte: 2020.08.13.
  //        |Szállítólevél száma: NYEUR 20/0000572KI
  //        |Szállítólevél kelte: 2020.08.12.
  //        |Nettó súly: 8400 kg [2020_0010]
  //        |Termékkód: 2020_0010
  //        |Termék egyed:""".stripMargin
  //      val invoiceInfo = InvoiceInfo(comment)
  //      invoiceInfo shouldBe InvoiceInfo( "342590", "2020- 08- 13", "NYEUR 20/0000572KI", "2020- 08- 12", None)
  //    }
  //  }
}

