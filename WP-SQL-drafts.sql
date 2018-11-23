-- WORDPRESS SQL Statements

-- Delete all rows from Wordpress table older then X days.
DELETE FROM `umh_inbound_page_views` WHERE datetime < DATE_SUB(NOW(), INTERVAL 7 DAY)


-- Get USERS with some specific META VALUES
SELECT * FROM wp_users, wp_usermeta 
WHERE wp_users.ID = wp_usermeta.user_id 
AND wp_usermeta.meta_key = 'wp_optimizemember_login_counter' 
AND wp_usermeta.meta_value > 50


-- Get POSTS with specific META VALUES
SELECT * FROM wp_posts, wp_postmeta
WHERE wp_posts.ID = wp_postmeta.post_id 
AND wp_postmeta.meta_key = 'tag' 
AND wp_postmeta.meta_value = 'email' 
AND wp_posts.post_status = 'publish' 
AND wp_posts.post_type = 'post'
AND wp_posts.post_date < NOW()
ORDER BY wp_posts.post_date DESC

-- Get login count numer for FPP website
SELECT * FROM wp_users, wp_usermeta 
WHERE wp_users.ID = wp_usermeta.user_id 
AND wp_usermeta.meta_key = 'wp_optimizemember_login_counter' 
AND wp_usermeta.meta_value > 50

-- Get DISTINCT values of specific field in Wordpress
SELECT DISTINCT meta_value, meta_key FROM wp_postmeta WHERE meta_key = '_billing_email';

-- Find rows with the same values
SELECT meta_key, meta_value
FROM wp_postmeta
WHERE meta_key = '_billing_email'
GROUP BY meta_value 
HAVING ( COUNT(*) > 1 )


-- PP SQL Queries

-- Delete data from Thrive Leads Log older then X days
DELETE FROM wp_tve_leads_event_log WHERE date < NOW() - INTERVAL 60 DAY

-- Delete data from Thrive Leads Pageviews older then X days
DELETE FROM wp_inbound_page_views WHERE datetime < NOW() - INTERVAL 90 DAY





-- WOOCOMMERCE

-- Find customers that have purchased more then one product
SELECT post_id, meta_key, meta_value, ID, post_title, post_status, post_type FROM wp_postmeta
INNER JOIN wp_posts ON wp_postmeta.post_id = wp_posts.ID
WHERE meta_key = '_billing_email'
GROUP BY meta_value
HAVING COUNT(*)>1

-- Find posts based on some META VALUE
SELECT * FROM wp_posts WHERE ID IN (
    SELECT post_id FROM wp_postmeta
    WHERE wp_postmeta.meta_key = '_price' AND wp_postmeta.meta_value > 2
)

-- Return a list of product categories
SELECT wp_terms.* 
	FROM wp_terms 
	LEFT JOIN wp_term_taxonomy ON wp_terms.term_id = wp_term_taxonomy.term_id
	WHERE wp_term_taxonomy.taxonomy = 'product_cat'

-- Get the category for a specific product
SELECT wp_term_relationships.*,wp_terms.* FROM wp_term_relationships
	LEFT JOIN wp_posts  ON wp_term_relationships.object_id = wp_posts.ID
	LEFT JOIN wp_term_taxonomy ON wp_term_taxonomy.term_taxonomy_id = wp_term_relationships.term_taxonomy_id
	LEFT JOIN wp_terms ON wp_terms.term_id = wp_term_relationships.term_taxonomy_id
	WHERE post_type = 'product' AND taxonomy = 'product_cat' 
	AND  object_id = 167

-- Return a list of line item details for a specific order
SELECT wp_woocommerce_order_itemmeta.*,wp_woocommerce_order_items.*
	FROM wp_woocommerce_order_items 
	JOIN wp_woocommerce_order_itemmeta ON wp_woocommerce_order_itemmeta.order_item_id = wp_woocommerce_order_items.order_item_id
	WHERE order_id = 7373
	ORDER BY wp_woocommerce_order_itemmeta.meta_key

-- Order total for all orders
SELECT post_id AS order_number, 
	meta_value AS order_total 
	FROM wp_postmeta WHERE meta_key = '_order_total' ORDER BY post_id

-- Order total for specific orders
SELECT post_id AS order_number, 
	meta_value AS order_total 
	FROM wp_postmeta WHERE meta_key = '_order_total' AND post_id = 1770	


 -- List every product and it's prices
SELECT
	postmeta1.meta_value AS sku,
	postmeta2.meta_value AS regular_price,
	postmeta3.meta_value AS sale_price,
	postmeta4.meta_value AS price

FROM
wp_posts
	LEFT JOIN wp_postmeta postmeta1 ON (postmeta1.post_id = wp_posts.ID AND postmeta1.meta_key = '_sku')
	LEFT JOIN wp_postmeta postmeta2 ON (postmeta2.post_id = wp_posts.ID AND postmeta2.meta_key = '_regular_price')
	LEFT JOIN wp_postmeta postmeta3 ON (postmeta3.post_id = wp_posts.ID AND postmeta3.meta_key = '_sale_price')
	LEFT JOIN wp_postmeta postmeta4 ON (postmeta4.post_id = wp_posts.ID AND postmeta4.meta_key = '_price')
WHERE post_type = 'product'


-- Select Query for Retrieving WooCommerce Order Items and Meta Data
SELECT
wp_woocommerce_order_items.order_id,
wp_woocommerce_order_items.order_item_id,
wp_woocommerce_order_items.order_item_name,
wp_woocommerce_order_items.order_item_type,

max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_product_id' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as productID,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_qty' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as Qty,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_variation_id' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as variationID,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_line_total' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as lineTotal,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_line_subtotal_tax' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as subTotalTax,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_line_tax' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as Tax,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_tax_class' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as taxClass,
max( CASE WHEN wp_woocommerce_order_itemmeta.meta_key = '_line_subtotal' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id THEN wp_woocommerce_order_itemmeta.meta_value END ) as subtotal

FROM
	wp_woocommerce_order_items,
	wp_woocommerce_order_itemmeta
WHERE order_item_type = 'line_item' and wp_woocommerce_order_items.order_item_id = wp_woocommerce_order_itemmeta.order_item_id
GROUP BY wp_woocommerce_order_items.order_item_id



-- Get complete orders INFO about each order FAST
SELECT
    p.ID AS order_id,
    p.post_date,
    max( CASE WHEN pm.meta_key = '_billing_email' AND p.ID = pm.post_id THEN pm.meta_value END ) as billing_email,
    max( CASE WHEN pm.meta_key = '_billing_first_name' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_first_name,
    max( CASE WHEN pm.meta_key = '_billing_last_name' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_last_name,
    max( CASE WHEN pm.meta_key = '_billing_address_1' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_address_1,
    max( CASE WHEN pm.meta_key = '_billing_address_2' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_address_2,
    max( CASE WHEN pm.meta_key = '_billing_city' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_city,
    max( CASE WHEN pm.meta_key = '_billing_state' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_state,
    max( CASE WHEN pm.meta_key = '_billing_postcode' AND p.ID = pm.post_id THEN pm.meta_value END ) as _billing_postcode,
    max( CASE WHEN pm.meta_key = '_shipping_first_name' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_first_name,
    max( CASE WHEN pm.meta_key = '_shipping_last_name' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_last_name,
    max( CASE WHEN pm.meta_key = '_shipping_address_1' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_address_1,
    max( CASE WHEN pm.meta_key = '_shipping_address_2' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_address_2,
    max( CASE WHEN pm.meta_key = '_shipping_city' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_city,
    max( CASE WHEN pm.meta_key = '_shipping_state' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_state,
    max( CASE WHEN pm.meta_key = '_shipping_postcode' AND p.ID = pm.post_id THEN pm.meta_value END ) as _shipping_postcode,
    max( CASE WHEN pm.meta_key = '_order_total' AND p.ID = pm.post_id THEN pm.meta_value END ) as order_total,
    max( CASE WHEN pm.meta_key = '_order_tax' AND p.ID = pm.post_id THEN pm.meta_value END ) as order_tax,
    max( CASE WHEN pm.meta_key = '_paid_date' AND p.ID = pm.post_id THEN pm.meta_value END ) as paid_date,
    ( select group_concat( order_item_name separator '|' ) from wp_woocommerce_order_items WHERE order_id = p.ID ) as order_items
FROM
    wp_posts AS p 
    JOIN wp_postmeta pm ON p.ID = pm.post_id
    JOIN wp_woocommerce_order_items oi ON p.ID = oi.order_id
WHERE
    post_type = 'shop_order' AND
    post_date BETWEEN '2015-01-01' AND '2017-07-08' AND
    post_status = 'wc-completed' AND
    oi.order_item_name = 'Formula za Fit Tijelo'
GROUP BY
    p.ID

