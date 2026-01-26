package br.com.spark.transferencia.enuns;

public enum Tipo {
	
	 PEDIDO("P"),
	 SAIDA("V"),
	 ENTRADA("C");
	 private String opcao;
	 
	 Tipo(String opcao){
		 this.opcao = opcao;
	 }
	
}
