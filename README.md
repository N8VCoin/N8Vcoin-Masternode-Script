![N8Vcoin-Logo](https://i.imgur.com/j0uzmcV.png)
# NativeCoin Masternode Setup Guide Ubuntu 18.04
This guide will assist you in setting up a N8Vcoin Masternode on a Linux Server running Ubuntu 18.04. (Use at your own risk)

If you require further assistance contact the support team @ [Discord](https://discord.gg/YQqBKT2) or [Telegram](https://t.me/NativeCoinOfficial)
***
## Requirements
1) **25,000 N8V coins.**
2) **A Vultr VPS running Linux Ubuntu 18.04**
3) **A Windows local wallet.**
4) **An SSH client such as [Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe)**
***
## Contents
* **Section A**: Creating the VPS within [Vultr](https://www.vultr.com/?ref=7296974).
* **Section B**: Downloading and installing Bitvise.
* **Section C**: Connecting to the VPS and installing the MN script via Bitvise.
* **Section D**: Preparing the local wallet.
* **Section E**: Connecting & Starting the masternode.
***

## Section A: Creating the VPS within [Vultr](https://www.vultr.com/?ref=7296974)
***Step 1***
* Register at [Vultr](https://www.vultr.com/?ref=7296974)
***

***Step 2***
* After you have added funds to your account go [here](https://my.vultr.com/deploy/) to create your Server
***

***Step 3***
* Choose a server location (preferably somewhere close to you)
![Example-Location](https://i.imgur.com/ozi7Bkr.png)
***

***Step 4***
* Choose a server type: Ubuntu 18.04
![Example-OS](https://i.imgur.com/kRsY2er.png)
***

***Step 5***
* Choose a server size: $5/mo will be fine
![Example-OS](https://i.imgur.com/UoGoHcM.png)
***

***Step 6***
* Set a Server Hostname & Label (name it whatever you want)
![Example-hostname](https://i.imgur.com/uu0rvOr.png)
***

***Step 7***
* Click "Deploy now"

![Example-Deploy](https://i.imgur.com/4qpYuH0.png)
***


## Section B: Downloading and installing BitVise.

***Step 1***
* Download Bitvise [here](https://dl.bitvise.com/BvSshClient-Inst.exe)
***

***Step 2***
* Select the correct installer depending upon your operating system. Then follow the install instructions.

![Example-PuttyInstaller](https://i.imgur.com/yF3694G.png)
***


## Section C: Connecting to the VPS & Installing the MN script via Bitvise.

***Step 1***
* Copy your VPS IP (you can find this by going to the server tab within Vultr and clicking on your server.
![Example-Vultr](https://i.imgur.com/9pQtldT.png)
***

***Step 2***
* Open the bitvise application and fill in the "Hostname" box with the IP of your VPS and PORT ***22***.
![Example-PuttyInstaller](https://i.imgur.com/lhpvq10.png)
***

***Step 3***
* Copy the root password from the VULTR server page.
![Example-RootPass](https://i.imgur.com/JnXQXav.png)
***

***Step 4***
* Type "root" as the login/username. Make Sure Both Boxes are checked!
![Example-Root](https://i.imgur.com/BrT9a7i.png)
***

***Step 5***
* Paste the password into the Bitvise terminal by right clicking (it will not show the password so just press enter)
![Example-RootPassEnter](https://i.imgur.com/GCyPXnL.png) 
***

***Step 6***
* Once you have clicked open it will open a security alert (click yes).  
***

***Step 7***
* Paste the code below into the Bitvise terminal then press enter (it will just go to a new line)
![Example-RootPassEnter](https://i.imgur.com/ZnTInlO.png)

`wget -q https://raw.githubusercontent.com/N8VCoin/N8Vcoin-Masternode-Script/master/n8v_install.sh`
***

***Step 8***
* Paste the code below into the Bitvise terminal then press enter

`bash n8v_install.sh`

![Example-Bash](https://i.imgur.com/ENZvcHk.png)

***

***Step 9***
* Sit back and wait for the install (this will take 10-20 mins)

![Example-installing](https://i.imgur.com/HFFBcQU.png)
***

***Step 10***
* When prompted to enter your Gen key - Paste your genkey from going to Tools Debug Console ***"createmasternodekey"***

![Example-installing](https://i.imgur.com/JsnyxQn.png)
***

***Step 11***
* You will now see all of the relavant information for your server.
* Keep this terminal open as we will need the info for the wallet setup.
![Example-installing](https://i.imgur.com/goGoFhS.png)
***

## Section D: Preparing the Local wallet

***Step 1***
* Download and install the N8V wallet [here](https://github.com/N8VCoin/N8Vcoin/releases)
***

***Step 2***
* Send EXACLY 25,000 N8V to a receive address within your wallet.
***

***step 3***
* Go to the console within the wallet

![Example-console](https://i.imgur.com/6u17sDA.png)
***

***Step 4***
* Type the command below and press enter

`getmasternodeoutputs`

![Example-outputs](https://i.imgur.com/RMe8oJs.png)
***

***Step 5***
* Copy the long key (this is your transaction ID) and the 1 or 2 at the end (this is your output index)
***

# Section E: Connecting & Starting the masternode

***Step 1***
* Go to the tools tab within the wallet and click open "masternode configuration file"
![Example-create](https://i.imgur.com/SW4UDYV.png)
***

***Step 2***

* Fill in the form.
* For `Alias` type something like "MN01" **don't use spaces**
* The `Address` is the IP and port of your server (this will be in the Bitvise terminal that you still have open).
* The `PrivKey` is your masternode GEN key (This is also in the Bitvise terminal that you have open).
* The `TxHash` is the transaction ID/long key that you copied to the text file.
* The `Output Index` is the 0 or 1 that you copied to your text file.
![Example-create](https://i.imgur.com/eomS3rT.png)

Click "File Save"
***

***Step 3***
* Close out of the wallet and reopen Wallet
*Click on the Masternodes tab "My masternodes"
* Click start all in the masternodes tab
***

***step 4***
* Check the status of your masternode within the VPS by using the command below:

`nativecoin-cli getmasternodestatus`

*You should see ***status 4***

![Example-create](https://i.imgur.com/IVpE2Wr.png)

If you do, congratulations! You have now setup a masternode. If you do not, please contact support and they will assist you.  
***
