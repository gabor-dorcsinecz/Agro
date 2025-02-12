import org.apache.poi.xssf.usermodel.XSSFWorkbook
import scalafx.application.JFXApp3
import scalafx.scene.Scene
import scalafx.scene.control.{Button, TextArea}
import scalafx.stage.FileChooser
import scalafx.scene.layout.{HBox, Priority, Region, VBox}

import java.io.{File, FileInputStream}
import java.nio.charset.{Charset, StandardCharsets}
import java.nio.file.{Files, Path, Paths}
import java.text.SimpleDateFormat
import java.time.LocalDate
import scala.io.Source
import scala.util.Using
import BankTransaction.*
import scalafx.geometry.Insets
import scalafx.stage

object AgroFileConvertersApp extends JFXApp3 {

  override def start(): Unit = {
    val textArea = new TextArea {
      editable = false
      prefHeight = 500
    }

    val btnConvertInvoiceXml = new Button("Convert Invoice XML") {
      onAction = _ => {
        val fileChooser = new FileChooser {
          title = "Open File(s)"
          extensionFilters.add(new FileChooser.ExtensionFilter("XML Files", Seq("*.xml")))
        }

        fileChooser.showOpenMultipleDialog(stage)
          .map { file =>
            val outputFile = new File(file.getAbsolutePath.substring(0, file.getAbsolutePath.lastIndexOf(".")) + "-OUT.Xml")
            val output = InvoiceTransformer.transformFile(file,outputFile)
            textArea.appendText(s"Output File name and location: \r\n  ${output.getAbsolutePath}\r\n")
          }
      }
    }

    val btnKsToKH = new Button("Kulcs-Soft Transactions to K&H Bank import") {
      onAction = _ => {
        val fileChooser = new FileChooser {
          title = "Open File(s)"
          extensionFilters.add(new FileChooser.ExtensionFilter("Excel Files", Seq("*.xls", "*.xlsx")))
        }

        fileChooser.showOpenMultipleDialog(stage)
          .map { file =>
            val outputPath = convertXlsxToHUF(file)
            textArea.appendText(s"Output File name and location: \r\n  ${outputPath.toAbsolutePath}\r\n")
          }
      }
    }
    //btnKsToKH.setPadding(new Insets(10))

    val btnReverse = new Button("Reverse Order") {
      onAction = _ => {
        val fileChooser = new FileChooser {
          title = "Open File(s)"
        }

        fileChooser.showOpenMultipleDialog(stage)
          .map { file =>
            val outputPath = rearrangeKHTransactions(file)
            textArea.appendText(s"Output File name and location: \r\n  ${outputPath.toAbsolutePath}\r\n")
          }
      }
    }


    stage = new JFXApp3.PrimaryStage {
      title = "AgroX Company Utilities"
      List(btnConvertInvoiceXml , btnKsToKH, btnReverse).foreach{ btn =>
        VBox.setVgrow(btn, Priority.Always)
        btn.maxHeight = Double.MaxValue // Allows buttons to stretch
        btn.minHeight = Region.USE_COMPUTED_SIZE // Uses calculated height
      }

      val vbox = new VBox(50, btnConvertInvoiceXml , btnKsToKH, btnReverse){
        padding = Insets(50)
        vgrow = Priority.Always // Make VBox itself stretch
      }
//      VBox.setVgrow(btnConvertInvoiceXml, Priority.Always)
//      VBox.setVgrow(btnKsToKH, Priority.Always)
//      VBox.setVgrow(btnReverse, Priority.Always)


      val hbox = new HBox(10, vbox, textArea) {
        padding = Insets(10)
      }

      scene = new Scene {
        root = hbox
      }
      scene.value.getRoot.setStyle("-fx-font-size: 20px;")
    }

  }

  def rearrangeKHTransactions(file: File): Path = {
    val parsed = BankAccounts.parseBankData(file.toPath)
    val outputFileName = file.getAbsolutePath.substring(0, file.getAbsolutePath.lastIndexOf(".")) + "-REVERSE.STM"
    Files.write(Paths.get(outputFileName), parsed.toSTMFile().getBytes(Charset.forName("ISO-8859-2")))
  }

  def convertXlsxToHUF(file: File): Path = {
    val bankTransactions = extractXlsx(file)
    val outputFileName = file.getAbsolutePath.substring(0, file.getAbsolutePath.lastIndexOf(".")) + ".HUF"
    Files.write(Paths.get(outputFileName), bankTransactions.map(_.toTransactionLine()).mkString("", "\r\n", "\r\n").getBytes(StandardCharsets.US_ASCII))
  }

  def extractXlsx(file: File): Seq[BankTransaction] = {

    Using.Manager { use =>
      val fileInputStream = use(new FileInputStream(file))
      val workbook = use(new XSSFWorkbook(fileInputStream))

      val sheet = workbook.getSheetAt(0) // Read the first sheet

      val sourceCompanyName = Option(sheet.getRow(2).getCell(0)).map(_.toString).getOrElse("")
      val sourceBankAccountNumber = BankTransaction.companyNameToAccountNumber(sourceCompanyName)

      (4 until sheet.getPhysicalNumberOfRows).map { row =>
        Option(sheet.getRow(row)).flatMap(row => {
          row.getPhysicalNumberOfCells match {
            case 6 =>
              val s = Some(BankTransaction(
                sourceBankAccountNumber = AccountNumber(sourceBankAccountNumber),
                sourceCompanyName = AsciiString(sourceCompanyName),
                targetBankAccountNumber = AccountNumber(row.getCell(4).toString),
                targetCompanyName = AsciiString(row.getCell(2).toString),
                comment = AsciiString(row.getCell(0).toString),
                amount = BigDecimal(row.getCell(6).toString),
                date = LocalDate.now()
              ))
              //println(row.getCell(4).toString + "    " + clearAccountNumber(row.getCell(4).toString))
              println(s)
              s.foreach(x => println(x.toTransactionLine()))
              s
            case _ => None
          }
        })
      }.flatten


      //      workbook.close()
      //      fileInputStream.close()
    }.getOrElse(Nil)
  }


}
