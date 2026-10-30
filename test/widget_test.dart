import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_mobile/main.dart';

// Testes simples que não exigem GPS, rede ou Firebase configurado.
void main() {
  test('O cardápio do 67 Delivery tem produtos cadastrados', () {
    expect(foods, isNotEmpty);
  });

  test('Formata os valores em reais', () {
    expect(reais(29.90), r'R$ 29,90');
  });

  test('Há pratos de churrasco, açaí, sorvete e milk-shake', () {
    final categories = foods.map((food) => food.category).toSet();
    expect(categories, containsAll(['Churrasco', 'Açaí', 'Sorvetes', 'Milk-shakes']));
  });
}
