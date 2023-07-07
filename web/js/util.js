/*
JavaScript Utility for EtherVac
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This script is a small JavaScript utility library specially designed for the
project. Contains useful functions to shorten the code.

Must be used together with JavaScript Helper.

*/

let nonce = "";

function getNonce(rc = null) {
	if (rc == null) {
		XHRequest("getNonce", JSON.stringify({}), { callback: "getNonce", async: false });
	} else {
		nonce = rc["uuid"];
	}
}

async function connectWallet() {
	let address = null;
	let errMsg = null;

	if (typeof window.ethereum === 'undefined') {
		errMsg = "Please install MetaMask in your browser.";
	} else if (!ethereum.isMetaMask) {
		errMsg = "Please install MetaMask in your browser.";
	} else {
		await ethereum.request({
			method: "eth_requestAccounts"
		}).then(() => {
			address = ethereum.selectedAddress;
		}).catch((error) => {
			if (error.code == 4001) {
				errMsg = "Connect wallet rejected.";
			} else {
				errMsg = "Unable to connect to wallet.";
			}
		});
	}

	if (errMsg != null) return Promise.reject(errMsg);
	return address;
}

async function signMessage(message, address) {
	let signature = null;
	let errMsg = null;

	if (typeof window.ethereum === 'undefined') {
		errMsg = "Please install MetaMask in your browser.";
	} else if (!ethereum.isMetaMask) {
		errMsg = "Please install MetaMask in your browser.";
	} else {
		if (message == null || message == "") {
			errMsg = "Error: Empty message";
		} else if (address == null || address == "") {
			errMsg = "Error: Empty address.";
		} else {
			await ethereum.request({
				method: "personal_sign",
				params: [message, address]
			}).then((_signature) => {
				signature = _signature;
			}).catch((error) => {
				if (error.code == -32603) {
					errMsg = "Sign message rejected.";
				} else {
					errMsg = "Unable to sign message.";
				}
			});
		}
	}

	if (errMsg != null) return Promise.reject(errMsg);
	return signature;
}