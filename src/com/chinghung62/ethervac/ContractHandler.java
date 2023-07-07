package com.chinghung62.ethervac;

import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigInteger;
import java.util.Properties;

import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.gas.ContractGasProvider;
import org.web3j.tx.gas.StaticGasProvider;

public class ContractHandler {
	private Web3j web3j;
	private Credentials credentials;
	private BigInteger gasPrice;
	private BigInteger gasLimit;
	private StaticGasProvider gasProvider;
	private String contractAddress;

	public ContractHandler() {
		Properties properties = new Properties();

		try (FileInputStream configFile = new FileInputStream("ethereum_config.ini")) {
			properties.load(configFile);
			this.web3j = Web3j.build(new HttpService(properties.getProperty("node_api_url")));
			this.credentials = Credentials.create(properties.getProperty("private_key"));
			this.gasPrice = new BigInteger(properties.getProperty("gas_price"));
			this.gasLimit = new BigInteger(properties.getProperty("gas_limit"));
			this.gasProvider = new StaticGasProvider(this.gasPrice, this.gasLimit);
			this.contractAddress = properties.getProperty("contract_address");
		} catch (IOException e) {
			System.out.println("Error! ContractHandler(): " + e);
		}
	}

	public Object load(String contractWrapperClassName) {
		try {
			Class<?> wrapperClass = Class.forName("com.chinghung62.ethervac." + contractWrapperClassName);
			Method m = wrapperClass.getMethod("load", String.class, Web3j.class, Credentials.class,
					ContractGasProvider.class);

			return m.invoke(null, this.contractAddress, this.web3j, this.credentials, this.gasProvider);
		} catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException
				| InvocationTargetException e) {
			System.out.println("Error! ContractHandler.load(): " + e);
		}

		return null;
	}
}
