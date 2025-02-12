import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.concurrent.atomic.AtomicLong
import scala.collection.immutable

opaque type AsciiString = String

object AsciiString {

  def apply(name: String): AsciiString = replaceHungarianVowels(name)

  def replaceHungarianVowels(text: String): String = {
    val replacements: Map[Char, Char] = Map(
      // Lowercase replacements
      'á' -> 'a', 'é' -> 'e', 'í' -> 'i', 'ó' -> 'o', 'ö' -> 'o', 'ő' -> 'o', 'ú' -> 'u', 'ü' -> 'u', 'ű' -> 'u',
      'Á' -> 'A', 'É' -> 'E', 'Í' -> 'I', 'Ó' -> 'O', 'Ö' -> 'O', 'Ő' -> 'O', 'Ú' -> 'U', 'Ü' -> 'U', 'Ű' -> 'U'
    )
    text.map(c => replacements.getOrElse(c, c)) // Replace characters if found in map
  }
}

extension (as: AsciiString) {
  def value: String = as
}


opaque type AccountNumber = String

object AccountNumber {
  def apply(number: String): AccountNumber = clearAccountNumber(number)

  def clearAccountNumber(number: String): String = number.replaceAll("[^0-9]", "")
}

extension (an: AccountNumber) {
  def number: String = an
}

case class BankTransaction(
                            sourceBankAccountNumber: AccountNumber,
                            sourceCompanyName: AsciiString,
                            targetBankAccountNumber: AccountNumber,
                            targetCompanyName: AsciiString,
                            comment: AsciiString,
                            amount: BigDecimal,
                            date: LocalDate,
                            transactionId: Long = BankTransaction.getTransactionId()
                          ) {

  def formatSourceBankAccountNumber(): String = {
    val lineData = "PAYORDDO" + BankTransaction.dateFormat.format(LocalDate.now()) + String.format("%06d", transactionId)  + BankTransaction.companyNameToAccountNumber(sourceCompanyName.value)
    lineData.padTo(69, ' ')
  }

  def toTransactionLine(): String = {
    formatSourceBankAccountNumber() +
      "0" + sourceCompanyName.value.padTo(149, ' ') +
      targetBankAccountNumber.number.padTo(47, ' ') +
      "0".padTo(65, ' ') +
      targetCompanyName.value.padTo(140, ' ') +
      "HU".padTo(121, ' ') +
      comment.value.padTo(96, ' ') +
      transactionId.toString.padTo(7, ' ') +
      "000".padTo(110, ' ') +
      "HUF" + String.format("%014d", amount.toBigInt.toLong) + "".padTo(12, ' ') +
      BankTransaction.dateFormat.format(date).padTo(103, ' ') +
      "00"

  }
}

object BankTransaction {
  val dateFormat = DateTimeFormatter.ofPattern("yyyyMMdd")

  def companyNameToAccountNumber(name: String): String = {
    val lowName = name.toLowerCase()
    if (lowName.startsWith("agroszt")) {
      "104026232621044300000000"
    } else if (lowName.startsWith("dombegyh")) {
      "104026232621331200000000"
    } else if (lowName.startsWith("kisdombegyh")) {
      "104026232621208100000000"
    } else {
      "--COMPANY-NOT-FOUND--"
    }
  }

  val transactionID = AtomicLong()

  def getTransactionId(): Long = {
    transactionID.incrementAndGet()
  }
}
