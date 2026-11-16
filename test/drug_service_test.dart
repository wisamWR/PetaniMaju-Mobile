import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/services/drug_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('katalog obat termuat dari aset', () async {
    final drugs = await DrugService().getDrugs();
    expect(drugs.length, 40);
    expect(await DrugService().getCategories(), contains('Fungisida'));
  });

  test('rekomendasi obat sesuai tanaman & penyakit', () async {
    final result = await DrugService()
        .recommend(plantType: 'Tomat', disease: 'Late Blight (Phytophthora infestans)');
    expect(result, isNotEmpty);
    expect(result.every((d) => d.tanaman.contains('Tomat')), isTrue);
  });

  test('tanaman sehat tidak butuh obat', () async {
    expect(await DrugService().recommend(plantType: 'Padi', disease: 'Sehat'), isEmpty);
  });

  test('cari obat berdasarkan nama dari tag chatbot', () async {
    final found = await DrugService().findByNames(['dithane m-45', 'Tidak Ada']);
    expect(found.map((d) => d.nama), ['Dithane M-45']);
  });
}
