// Memverifikasi status transaksi langsung ke Midtrans (bukan percaya client),
// lalu mengaktifkan PRO di tabel user_premium bila pembayaran lunas.
// Body: { orderId }
// Balasan: { status, premium }
import {
  adminClient,
  CORE_API_URL,
  corsHeaders,
  getUser,
  json,
  midtransAuthHeader,
  PLANS,
} from "../_shared/midtrans.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const user = await getUser(req);
    if (!user) return json({ error: "Sesi tidak valid." }, 401);

    const { orderId } = await req.json().catch(() => ({}));
    if (!orderId) return json({ error: "orderId wajib diisi." }, 400);

    const admin = adminClient();
    const { data: order } = await admin
      .from("premium_orders")
      .select("*")
      .eq("order_id", orderId)
      .eq("user_id", user.id)
      .maybeSingle();
    if (!order) return json({ error: "Order tidak ditemukan." }, 404);
    if (order.status === "paid") return json({ status: "settlement", premium: true });

    const res = await fetch(`${CORE_API_URL}/${encodeURIComponent(orderId)}/status`, {
      headers: { Accept: "application/json", Authorization: midtransAuthHeader() },
    });
    const trx = await res.json();
    const status: string = trx.transaction_status ?? "unknown";

    const paid =
      status === "settlement" ||
      (status === "capture" && trx.fraud_status === "accept");
    const amountOk = Math.round(Number(trx.gross_amount)) === order.amount;

    if (paid && amountOk) {
      // Update bersyarat agar masa aktif tidak ditambah dua kali.
      const { data: claimed } = await admin
        .from("premium_orders")
        .update({ status: "paid", paid_at: new Date().toISOString() })
        .eq("order_id", orderId)
        .eq("status", "pending")
        .select()
        .maybeSingle();

      if (claimed) {
        const { data: current } = await admin
          .from("user_premium")
          .select("premium_until")
          .eq("user_id", user.id)
          .maybeSingle();

        const now = Date.now();
        const currentUntil = current?.premium_until ? Date.parse(current.premium_until) : 0;
        const base = Math.max(now, currentUntil);
        const until = new Date(base + order.days * 24 * 60 * 60 * 1000);

        await admin.from("user_premium").upsert({
          user_id: user.id,
          is_premium: true,
          premium_until: until.toISOString(),
          premium_plan: PLANS[order.plan_id]?.name ?? order.plan_id,
          updated_at: new Date().toISOString(),
        });
      }
      return json({ status, premium: true });
    }

    if (["expire", "cancel", "deny", "failure"].includes(status)) {
      await admin
        .from("premium_orders")
        .update({ status })
        .eq("order_id", orderId)
        .eq("status", "pending");
    }

    return json({ status, premium: false });
  } catch (e) {
    console.error(e);
    return json({ error: (e as Error).message }, 500);
  }
});
