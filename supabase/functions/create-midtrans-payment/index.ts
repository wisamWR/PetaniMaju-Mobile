// Membuat transaksi Midtrans Snap untuk langganan PetaniMaju PRO.
// Body: { planId: "monthly" | "yearly" }
// Balasan: { order_id, token, redirect_url }
import {
  adminClient,
  corsHeaders,
  getUser,
  json,
  midtransAuthHeader,
  PLANS,
  SNAP_URL,
} from "../_shared/midtrans.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const user = await getUser(req);
    if (!user) return json({ error: "Sesi tidak valid. Silakan login ulang." }, 401);

    const { planId } = await req.json().catch(() => ({}));
    const plan = PLANS[planId as string];
    if (!plan) return json({ error: "Paket tidak dikenal." }, 400);

    const orderId = `PM-${Date.now()}-${user.id.slice(0, 8)}`;

    const snapRes = await fetch(SNAP_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: midtransAuthHeader(),
      },
      body: JSON.stringify({
        transaction_details: { order_id: orderId, gross_amount: plan.price },
        item_details: [
          { id: planId, price: plan.price, quantity: 1, name: plan.name },
        ],
        customer_details: { email: user.email },
      }),
    });

    const snap = await snapRes.json();
    if (!snapRes.ok || !snap.redirect_url) {
      console.error("Midtrans error", snapRes.status, snap);
      return json({ error: "Gagal membuat tagihan di Midtrans." }, 502);
    }

    const { error } = await adminClient().from("premium_orders").insert({
      order_id: orderId,
      user_id: user.id,
      plan_id: planId,
      amount: plan.price,
      days: plan.days,
    });
    if (error) {
      console.error("Insert order error", error);
      return json({ error: "Gagal menyimpan order." }, 500);
    }

    return json({
      order_id: orderId,
      token: snap.token,
      redirect_url: snap.redirect_url,
    });
  } catch (e) {
    console.error(e);
    return json({ error: (e as Error).message }, 500);
  }
});
