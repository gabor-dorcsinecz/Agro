import org.scalatest.funsuite.AnyFunSuite
import AgroFileConvertersApp.*
import org.scalatest.*
import org.scalatest.matchers.*

import java.io.File
import java.nio.file.{Files, Path}
import java.time.LocalDate

class BankTrasactionSpec extends AnyFunSuite with should.Matchers {

  test("Bank transaction is succesfully extracted") {
    val inputFile = new File("src/test/resources/KulcsExport.xlsx")
    val transactions = extractXlsx(inputFile)
    transactions.length shouldBe 1
    val expected = BankTransaction(
      AccountNumber("104026232621044300000000"),
      AsciiString("AGROSZTAR Kft."),
      AccountNumber("101047895625630001004004"),
      AsciiString("Dunavet-B Zrt."),
      AsciiString("VR136221"),
      1175180,
      LocalDate.now(),
      1
    )
    transactions(0) shouldBe expected
    val expectedLine = "PAYORDDO20250212000001104026232621044300000000                       0AGROSZTAR Kft.                                                                                                                                       101047895625630001004004                       0                                                                Dunavet-B Zrt.                                                                                                                              HU                                                                                                                       VR136221                                                                                        1      000                                                                                                           HUF00000001175180            20250212                                                                                               00"
    transactions(0).toTransactionLine() shouldBe expectedLine
  }

}
