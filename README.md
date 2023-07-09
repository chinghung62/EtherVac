# EtherVac: A Vaccination E-Certification using Ethereum

EtherVac is an innovative vaccination e-certification system that harnesses the power of Ethereum blockchain to provide a secure, tamper-proof, and convenient solution for managing vaccination certificates. EtherVac is a web-based system that is developed using Java and Java Servlet Pages (JSP), utilizing Solidity smart contract to securely store vaccination certificates. EtherVac takes user authentication to the next level by implementing a password-less login, where users can easily access the system using their MetaMask wallet. With EtherVac, clinic can sign and issue vaccination certificates to the patients. While patients can download certificates in PDF file and then verify it by scanning the QR code contained within the certificate. All certificates will be stored in the smart contract deployed into Ethereum Sepolia test network.

EtherVac implements a centralized account transaction model, which utilizes one central account for all transactions when performing data update on smart contract. It also implements the Elliptic Curve Digital Signature Algorithm (ECDSA) to guarantee the certificates authenticity.

# Prerequisites
The system requires every user to have their own account on the Ethereum blockchain. Any of Web3 enabled browser like [Google Chrome](https://www.google.com/chrome/) is required for the usage of MetaMask crypto wallet. User is required to install [MetaMask](https://metamask.io/) extension to their browser then create a new crypto account. Don't forget to get free SepoliaETH tokens via [Sepolia Faucets](#useful-tools--platforms).

# Quick Start
To quckly deploy EtherVac, it is required to follow the guidelines in order.

## Smart Contract Deployment
1. Download the [latest EtherVac release](https://github.com/chinghung62/EtherVac/releases/latest) then extract the ZIP file.
3. Upload all [smart contracts](Smart%20Contracts) (`.sol` file) to [Remix Ethereum IDE](https://remix.ethereum.org/). Compile `EtherVac.sol` using compiler with version 0.8.0 and above.
    <br>
    **Note:**
    > If an error `CompilerError: Stack too deep.` occurs, go to **Advanced Configurations** then select **Use configuration file**. Open the `compiler_config.json`, add `"viaIR": true` in the `settings` object, and compile the contract again.
4. Use crypto account to deploy the smart contract.
5. Contract address will be given after a successful contract deployment.

## Infura Web3 API Creation
1. Go to [Infura Dashboard](https://app.infura.io/dashboard) and create a new API key.
2. Copy Ethereum Sepolia HTTPS endpoint URL. The URL should look like `https://sepolia.infura.io/v3/<api_key>`.

## Ethereum Environment Configuration
Configure `ethereum_config.ini` by entering values for the keys below:
- `node_api_url` - The URL of the Web3 API endpoint.
- `private_key` - The private key of the crypto wallet account.
- `gas_price` - Gas price in unit 'wei'. 1000000000 wei is equivalent to 1 Gwei.
- `gas_limit` - To define the maximum transaction fee by formula *max_transaction_fee = gas_price * gas_limit*
- `contract_address` - The address of smart contract deployed using `private_key`.

## Startup Configuration
Edit `run.bat` and configure below variables **ONLY**:
- `HTTPS_PROXY_HOST` - IP address of the proxy server. Could also be the loopback address `127.0.0.1`.
- `HTTPS_PROXY_PORT` - Port number of the proxy server.

## Run!
Start EtherVac by executing `run.bat`.

# Development Setup (Windows 10 and above)
The system is developed using Java language, and runs on Java SE Development Kit (JDK) and Apache Tomcat 9 runtime environment. The system is built in the Eclipse IDE using a dynamic web project with Maven nature.

## Technical Requirements
There are several items required during development: runtime environments, IDEs, and useful tools and platforms for development. Besides, there are some libraries used in the system. Use `[Download]` hyperlink for quick download.

### Runtime Environments & IDEs
These are the runtime environments and IDEs which are required to be installed first before contributing to development.
- **Java SE Development Kit (Windows x64)** [\[Download\]](https://www.oracle.com/java/technologies/downloads/)<br>A cross-platform software development environment using Java technology by Oracle.
- **Eclipse IDE** [\[Download\]](https://www.eclipse.org/downloads/)<br>A Java Integrated Development Environment (IDE) software.
- **Apache Tomcat 9** [\[Download\]](https://tomcat.apache.org/download-90.cgi)<br>An open-source Java servlet and Java Server Page container.

### Useful Tools & Platforms
- **Smart contract IDE** - Used to develop, compile and deploy Solidity smart contracts.
    - [Remix Ethereum IDE](https://remix.ethereum.org/)<br>A powerful toolset for developing, deploying, debugging, and testing Ethereum and EVM-compatible smart contracts.
- **Smart contract converter** - Used to convert Solidity smart contracts to Java Wrapper Classes.
    - **web3j/web3j-cli** [\[GitHub\]](https://github.com/web3j/web3j-cli)<br>A command line tool enable developers to interact with blockchains more easily.
- **Sepolia faucets** - Used to get free SepoliaETH tokens to pay transaction fees when testing transactions on Sepolia test network.
    - [Infura Sepolia Faucet](https://www.infura.io/faucet/sepolia)
    - [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)
    - [Chainlink Faucets](https://faucets.chain.link/)
    - [All That Node Ethereum Faucet](https://www.allthatnode.com/faucet/ethereum.dsrv)

### Libraries Used
- **Web3j** `Maven: org.web3j|core|5.0.0`
- **Apache PDFBox** `Maven: org.apache.pdfbox|pdfbox|2.0.26`
- **ZXing Core** `Maven: com.google.zxing|core|3.5.1`
- **ZXing Java SE Extensions** `Maven: com.google.zxing|javase|3.5.1`
- **Google Gson** [\[Download\]](http://www.java2s.com/Code/Jar/g/gson.htm)
- **mebjas/html5-qrcode** [\[GitHub\]](https://github.com/mebjas/html5-qrcode)

## Source Code Download
Download the [source code](https://github.com/chinghung62/EtherVac/archive/refs/heads/main.zip) and extract the `EtherVac-main` folder from the ZIP file.

## Eclipse IDE Setup
### Java EE Installation
1. Navigate to **Help -> Install New Software...**.
2. Select a suitable site that matches to your Eclipse IDE version.
3. Check **Web, XML, Java EE and OSGi Enterprise Development**, click **Next** then click **Finish**.
4. After a complete installation and reboot, navigate to **Windows -> Perspective -> Open Perspective -> Other**. Choose **Java EE** and click **Open**.

### Create & Import Project
1. Navigate to **File -> New -> Dynamic Web Project**.
2. Enter **'EtherVac'** as the project name and choose **Apache Tomcat 9.0** as the target runtime, then click **Finish**.
3. Navigate to **File -> Import...**. Select **General -> File System** and click **Next**.
4. Click **Browse** for **From directory:** and select the `EtherVac-main` folder extracted earlier. Click **Select All** to import all files.
5. Click **Browse** for **Into folder:** and select the `EtherVac` project folder. Then click **Finish** to finish import.

### Apache Tomcat Server Runtime Setup
1. Navigate to **Window -> Preferences -> Server -> Runtime Environment**.
2. Click **Add**. Select **Apache -> Apache Tomcat v9.0** and click **Next**.
3. Click **Browse** and select the Apache Tomcat 9.0 main folder. Then click **Finish** followed by **Apply and Close**.
4. In the **Server** tab, **right click** then click **New -> Server**.
5. Select **Apache -> Apache Tomcat v9.0** then click **Next**.
6. Click **Add All >>** and click **Finish**.
7. Select the currently created project then navigate to **Project -> Properties -> Server**.
8. Select **Tomcat v9.0 Server at localhost** and click **Apply and Close**.
9. If you wish to change port number, simply replacing the value of the `port` attribute of the line below in `server.xml`:
    ```xml
    <Connector connectionTimeout="20000" port="8080" protocol="HTTP/1.1" redirectPort="8443"/>
    ```
    The `server.xml` file is located at **Server -> Tomcat v9.0 Server at localhost-config** in the **Explorer** tab. 
10. Copy [`ethereum_config.ini`](ethereum_config.ini) to the Eclipse IDE working directory. Usually this directory is located at `%HOMEDRIVE%%HOMEPATH%\eclipse\java-<yyyy>-<mm>\eclipse`.
11. Create a folder named `storage` at the Eclipse IDE working directory, then create two sub-folders: `certificates` and `qr` within it. Next, copy [`cert-template.pdf`](Certificate%20Templates/cert-template.pdf) to the `certificates` folder.
