class Produto {
  final int? id;
  final String nome;
  final double preco;
  final int quantidade;

  Produto({this.id, required this.nome, required this.preco, required this.quantidade,});

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
      quantidade: (json['quantidade'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
    };
  }
}
