import webpush from 'web-push';
import { createClient } from '@supabase/supabase-js';

webpush.setVapidDetails(
  process.env.VAPID_SUBJECT || 'mailto:rachelmavros1@gmail.com',
  process.env.VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
);

export default async function handler(req, res) {
  // Allow Vercel cron (GET) or manual trigger (POST)
  const secret = process.env.CRON_SECRET;
  if (secret) {
    const auth = req.headers['authorization'] || '';
    if (auth !== `Bearer ${secret}`) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
  }

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { data: subs, error } = await supabase
    .from('fortune_subscriptions')
    .select('endpoint, p256dh, auth');

  if (error) {
    console.error('Failed to fetch subscriptions:', error.message);
    return res.status(500).json({ error: 'DB error' });
  }

  if (!subs || subs.length === 0) {
    return res.status(200).json({ sent: 0, message: 'No subscribers' });
  }

  const payload = JSON.stringify({
    title: '🥠 Daily Fortune Cookie',
    body: "Your fortune for today is ready. What does the universe have to say?",
    url: '/'
  });

  const dead = [];
  let sent = 0;

  await Promise.all(
    subs.map(async sub => {
      try {
        await webpush.sendNotification(
          { endpoint: sub.endpoint, keys: { p256dh: sub.p256dh, auth: sub.auth } },
          payload
        );
        sent++;
      } catch (err) {
        if (err.statusCode === 404 || err.statusCode === 410) {
          dead.push(sub.endpoint);
        } else {
          console.error('Push error:', err.message);
        }
      }
    })
  );

  if (dead.length > 0) {
    await supabase
      .from('fortune_subscriptions')
      .delete()
      .in('endpoint', dead);
  }

  return res.status(200).json({ sent, removed: dead.length });
}
