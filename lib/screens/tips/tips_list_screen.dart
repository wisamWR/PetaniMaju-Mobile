import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/tip_model.dart';
import 'package:intl/intl.dart';

class TipsListScreen extends StatefulWidget {
  const TipsListScreen({super.key});

  @override
  State<TipsListScreen> createState() => _TipsListScreenState();
}

class _TipsListScreenState extends State<TipsListScreen> {
  late Future<List<Tip>> _tipsFuture;

  @override
  void initState() {
    super.initState();
    _tipsFuture = SupabaseService().getTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tips Bertani")),
      body: FutureBuilder<List<Tip>>(
        future: _tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final tips = snapshot.data ?? [];
          if (tips.isEmpty) {
            return const Center(child: Text("Belum ada tips."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              debugPrint("Tip: ${tip.judul}, ImageURL: ${tip.imageUrl}");
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.push('/tips/detail', extra: tip);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tip.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: tip.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) {
                            // debugPrint("Image Load Error: $error");
                            return CachedNetworkImage(
                              imageUrl: tip.getFallbackImage(),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.judul,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(tip.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tip.deskripsi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
