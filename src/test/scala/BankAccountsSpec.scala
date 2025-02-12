import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.*
import BankAccounts.*

import java.nio.charset.{Charset, StandardCharsets}
import java.nio.file.{Files, Path, Paths}

class BankAccountsSpec extends AnyFunSuite with should.Matchers {

  test("Compare Generated String with the correct file")  {
    val inputFile = parseBankData(Paths.get("src/test/resources/BankStatement.STM"))
    val expectedResult = Files.readString(Paths.get("src/test/resources/BankStatement-REVERSE.STM"), Charset.forName("ISO-8859-2"))
    expectedResult shouldBe inputFile.toSTMFile()
  }
}
