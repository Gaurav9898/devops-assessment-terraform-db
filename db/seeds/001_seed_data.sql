TRUNCATE TABLE booking_events, hotel_bookings RESTART IDENTITY;

INSERT INTO hotel_bookings (
  org_id,
  hotel_id,
  city,
  checkin_date,
  checkout_date,
  amount,
  status,
  created_at
)
SELECT
  (
    ARRAY[
      '11111111-1111-1111-1111-111111111111'::uuid,
      '22222222-2222-2222-2222-222222222222'::uuid,
      '33333333-3333-3333-3333-333333333333'::uuid,
      '44444444-4444-4444-4444-444444444444'::uuid
    ]
  )[(gs % 4) + 1] AS org_id,
  'hotel-' || lpad(((gs % 20) + 1)::text, 3, '0') AS hotel_id,
  (
    ARRAY['delhi', 'mumbai', 'bangalore', 'pune', 'jaipur']
  )[(gs % 5) + 1] AS city,
  (CURRENT_DATE + ((gs % 30) + 1))::date AS checkin_date,
  (CURRENT_DATE + ((gs % 30) + 3))::date AS checkout_date,
  (2500 + (gs * 37 % 9000))::numeric(12,2) AS amount,
  (
    ARRAY['confirmed', 'cancelled', 'pending', 'completed']
  )[(gs % 4) + 1] AS status,
  (NOW() - ((gs % 60) || ' days')::interval - ((gs % 24) || ' hours')::interval)::timestamp AS created_at
FROM generate_series(1, 150) AS gs;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
  id,
  'booking_created',
  jsonb_build_object('source', 'seed', 'city', city, 'status', status),
  created_at
FROM hotel_bookings
ORDER BY created_at DESC
LIMIT 100;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
  id,
  CASE
    WHEN status = 'cancelled' THEN 'booking_cancelled'
    WHEN status = 'completed' THEN 'checkout_completed'
    ELSE 'booking_updated'
  END,
  jsonb_build_object('source', 'seed', 'amount', amount),
  created_at + INTERVAL '1 day'
FROM hotel_bookings
WHERE status IN ('cancelled', 'completed', 'confirmed')
ORDER BY created_at DESC
LIMIT 75;
