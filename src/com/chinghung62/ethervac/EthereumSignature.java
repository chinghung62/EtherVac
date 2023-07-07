package com.chinghung62.ethervac;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.regex.Pattern;

import org.web3j.crypto.Credentials;
import org.web3j.crypto.ECDSASignature;
import org.web3j.crypto.Hash;
import org.web3j.crypto.Keys;
import org.web3j.crypto.Sign;
import org.web3j.crypto.Sign.SignatureData;
import org.web3j.utils.Numeric;

public class EthereumSignature {
	private static final String MESSAGE_PREFIX = "\u0019Ethereum Signed Message:\n";

	private static byte[] getMessagePrefix(int messageBytesLength) {
		return MESSAGE_PREFIX.concat(String.valueOf(messageBytesLength)).getBytes();
	}

	private static byte[] getMessageHash(String message) {
		byte[] messageBytes = message.getBytes(StandardCharsets.UTF_8);
		byte[] prefix = getMessagePrefix(messageBytes.length);

		byte[] result = new byte[prefix.length + messageBytes.length];
		System.arraycopy(prefix, 0, result, 0, prefix.length);
		System.arraycopy(messageBytes, 0, result, prefix.length, messageBytes.length);

		return Hash.sha3(result);
	}

	private static SignatureData parseSignature(String signature) {
		String regex = "^(0x)?[0-9A-Fa-f]{130}$";

		if (Pattern.compile(regex).matcher(signature).matches()) {
			byte[] signatureBytes = Numeric.hexStringToByteArray(signature);
			byte v = signatureBytes[64];
			byte[] r = (byte[]) Arrays.copyOfRange(signatureBytes, 0, 32);
			byte[] s = (byte[]) Arrays.copyOfRange(signatureBytes, 32, 64);

			if (v < 27) {
				v += 27;
			}

			return new SignatureData(v, r, s);
		}

		return null;
	}

	private static BigInteger generateKey(int id, SignatureData signatureData, byte[] messageHash) {
		try {
			return Sign.recoverFromSignature((byte) id,
					new ECDSASignature(Numeric.toBigInt(signatureData.getR()), Numeric.toBigInt(signatureData.getS())),
					messageHash);
		} catch (IllegalArgumentException e) {
			return null;
		}
	}

	public static String signMessage(String privateKey, String message) {
		Credentials credentials = Credentials.create(privateKey);
		byte[] messageBytes = message.getBytes(StandardCharsets.UTF_8);
		SignatureData signatureData = Sign.signPrefixedMessage(messageBytes, credentials.getEcKeyPair());
		byte[] signatureBytes = new byte[65];
		System.arraycopy(signatureData.getR(), 0, signatureBytes, 0, 32);
		System.arraycopy(signatureData.getS(), 0, signatureBytes, 32, 32);
		System.arraycopy(signatureData.getV(), 0, signatureBytes, 64, 1);
		return Numeric.toHexString(signatureBytes);
	}

	public static boolean verifySignature(String signature, String message, String address) {
		SignatureData signatureData = parseSignature(signature);
		byte[] messageHash = getMessageHash(message);

		if (signatureData != null) {
			int header = 0;

			for (byte b : signatureData.getV()) {
				header = (header << 8) + (b & 0xFF);
			}

			if (header < 27 || header > 34) {
				return false;
			}

			int id = header - 27;
			BigInteger publicKey = generateKey(id, signatureData, messageHash);

			if (publicKey != null) {
				String recoveredAddress = "0x" + Keys.getAddress(publicKey);

				if (recoveredAddress.equals(address)) {
					return true;
				}
			}
		}

		return false;
	}
}
