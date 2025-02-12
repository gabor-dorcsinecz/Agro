import java.io.File
import java.nio.charset.{Charset, StandardCharsets}
import java.nio.file.{Files, Path, Paths}
import scala.jdk.StreamConverters.*

/*
Bank Account Transaction
1 Rekordtípus 1 2 “12” (minden adatrekordban állandó)
2 Tranzakciótípus 3 6 Bankfüggő!
3 A tranzakció banki azonosítója 9 15
4 A megbízás összege 24 16 előjeles, 2 tizedes, tizedesvessző nélkül
5 A megbízás devizaneme 40 3
6 A megbízó bankja 1 43 35
7 A megbízó bankja 2 78 35
8 A megbízó bankja 3 113 35
9 A megbízó bankja 4 148 35
10 A megbízó neve 1 183 35
11 A megbízó neve 2 218 35
12 A megbízó neve 3 253 35
13 A megbízó neve 4 288 35
14 A megbízó számlaszáma 323 34
15 Közlemény 1 357 35
16 Közlemény 2 392 35
17 Közlemény 3 427 35
18 Közlemény 4 462 35
19 A kedvezményezett bankja 1 497 35
20 A kedvezményezett bankja 2 532 35
21 A kedvezményezett bankja 3 567 35
22 A kedvezményezett bankja 4 602 35
23 A kedvezményezett neve 1 637 35
24 A kedvezményezett neve 2 672 35
25 A kedvezményezett neve 3 707 35
26 A kedvezményezett neve 4 742 35
27 A kedvezményezett számlaszáma 777 34
28 Bizonylatszám 811 6
29 Határidő 817 8 Csak határidős inkasszó esetén
30 A jóváírás számlaszáma 825 24
31 A jóváírás devizaneme 849 3
32 A jóváírás végső összege 852 16 előjel, 2 tizedes, tizedesvessző nélkül
33 A jóváírás értéknapja 868 8 EEEEHHNN
34 A terhelés számlaszáma 876 24
35 A terhelés devizaneme 900 3
36 A terhelés végső összege 903 16 előjel, 2 tizedes, tizedesvessző nélkül
37 A terhelés értéknapja 919 8 EEEEHHNN
38 Megbízó országkód 927 2
39 Kedvezményezett országkód 929 2
40 Jogcímkód 931 3
41 A tranzakció banki azonosítója 934 35
42 Másodlagos azonosító típusa 969 4
43 Másodlagos azonosító 973 70
CR/LF 1043 2
*/

case class BankAccountFile(
                            accounts: List[BankAccount],
                            endOfFile: FileEndRecord
                          ) {
  def toSTMFile(): String = {
    val sep = "\r\n"
    accounts
      .map(acc => acc.rawLine + sep + acc.transactions.map(_.rawLine).mkString(sep) + sep + acc.footer.rawLine)
      .mkString(sep) + sep + endOfFile.rawLine + sep
  }
}

case class BankAccount(
                        accountNumber: String,
                        currency: String,
                        description: String,
                        transactions: List[BTransaction],
                        footer: BankAccountFooter,
                        rawLine: String
                      )

case class BTransaction(
                         referenceNumber: String,
                         amount: BigDecimal,
                         currency: String,
                         description: String,
                         rawLine: String
                       )

case class BankAccountFooter(rawLine: String)

case class FileEndRecord(rawLine: String)

object BankAccounts {

  def parseBankData(path: Path): BankAccountFile =
    val lines = Files.lines(path, Charset.forName("ISO-8859-2")).toScala(List)
    val accounts = scala.collection.mutable.ListBuffer.empty[BankAccount]
    var currentAccount: Option[BankAccount] = None
    //var currentFooter: Option[BankAccountFooter] = None
    var fileEndRecord: Option[FileEndRecord] = None
    val transactions = scala.collection.mutable.ListBuffer.empty[BTransaction]

    lines.foreach { line =>
      if line.startsWith("11") then
        currentAccount.foreach(acc => accounts += acc.copy(transactions = transactions.toList))  // Save the previous account if it had transactions
        transactions.clear()
        currentAccount = Some(parseAccountHeader(line))

      else if line.startsWith("12") then
        transactions += parseTransaction(line)

      else if line.startsWith("13") then
        currentAccount = currentAccount.map(_.copy(footer = BankAccountFooter(line)))

      else if line.startsWith("14") then
        fileEndRecord = Some(FileEndRecord(line))

      else
        println("Parsing Error")
    }

    // Add the last processed account
    currentAccount.foreach(acc => accounts += acc.copy(transactions = transactions.toList))

    val rearangedAccounts = accounts.toList.map { account =>
      val (neg, pos) = account.transactions.partition(_.amount <= 0)
      account.copy(transactions = pos ++ neg)
    }
    BankAccountFile(rearangedAccounts, fileEndRecord.get)


  // Parse account header from a line
  def parseAccountHeader(line: String): BankAccount =
    val accountNumber = line.substring(0, 15).trim
    val currency = line.substring(50, 53).trim
    val description = line.substring(15, 50).trim
    BankAccount(accountNumber, currency, description, List.empty, BankAccountFooter(""), line)

  // Parse transaction details from a line
  def parseTransaction(line: String): BTransaction =
    val referenceNumber = line.substring(0, 23).trim
    val rawAmountString = line.substring(23, 39).trim // Extracts the amount field
    val amountString = rawAmountString.replaceAll("[^0-9]", "") // Keep only digits

    // Ensure amountString is valid before conversion
    val amount = if amountString.nonEmpty then
      val numericAmount = BigDecimal(amountString)
      if rawAmountString.contains("-") then -numericAmount else numericAmount
    else
      BigDecimal(0) // Handle empty amount case gracefully

    val currency = line.substring(39, 42).trim
    val description = line.substring(60, 100).trim

    BTransaction(referenceNumber, amount, currency, description, line)

}