SELECT s.customer_id, p.plan_name, p.price, s.start_date
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p ON p.plan_id = s.plan_id
WHERE customer_id IN (1,2,11,19,468,517,48,62)
ORDER BY s.customer_id, s.start_date;