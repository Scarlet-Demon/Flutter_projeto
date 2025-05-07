import 'package:flutter/material.dart';
import 'produto.dart';
import 'produtos_service.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({Key? key}) : super(key: key);

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _produtosFuture = ProdutoService.getProdutos();
    });
  }

  void _mostrarDialogoProduto({Produto? produtoExistente}) {
    final nomeController = TextEditingController(text: produtoExistente?.nome ?? '');
    final precoController = TextEditingController(text: produtoExistente?.preco.toString() ?? '');
    final quantidadeController = TextEditingController(text: produtoExistente?.quantidade.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(produtoExistente == null ? 'Novo Produto' : 'Editar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: precoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Preço'),
            ),
            TextField(
              controller: quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantidade'),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nome = nomeController.text;
              final preco = double.tryParse(precoController.text) ?? 0.0;
              final quantidade = int.tryParse(quantidadeController.text) ?? 0;

              if (nome.isEmpty || preco <= 0 || quantidade <= 0) {
                // mostrar alerta ou retornar sem salvar
                 return;
              }

              if (produtoExistente == null) {
                await ProdutoService.addProduto(Produto(nome: nome, preco: preco, quantidade: quantidade));
              } else {
                await ProdutoService.updateProduto(
                  Produto(id: produtoExistente.id, nome: nome, preco: preco, quantidade: quantidade),
                );
              }

              Navigator.pop(context);
              _carregarProdutos();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(produtoExistente == null
                  ? 'Produto adicionado com Sucesso!'
                  : 'Produto atualizado com Sucesso!'),
                  duration: const Duration(seconds: 2)
              )
              );
            },
            child: Text(produtoExistente == null 
            ? 'Adicionar' 
            : 'Editar'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(int id) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: const Text('Deseja realmente excluir este produto?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 235, 19, 19),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await ProdutoService.deleteProduto(id);

            if (mounted) {
              Navigator.pop(context); 
              _carregarProdutos(); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produto excluído com sucesso!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          final produtos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _carregarProdutos();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return ListTile(
                title: Text(produto.nome),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                    Text('Quantidade: ${produto.quantidade}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      ),
                      onPressed: () => _mostrarDialogoProduto(produtoExistente: produto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 19, 19),
                      foregroundColor: Colors.white,
                      ),
                      onPressed: () => _confirmarExclusao(produto.id!),
                    ),
                   ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoProduto(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
