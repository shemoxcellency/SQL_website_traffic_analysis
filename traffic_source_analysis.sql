use mavenfuzzyfactory;
/*
Good morning,
We've been live for almost a month now and we’re starting to generate sales. Can you help me understand
where the bulk of our website sessions are coming from, through yesterday? I’d like to see a breakdown by
UTM source , campaign and referring domain if possible. Thanks!
*/ 
SELECT 
    utm_source, utm_campaign, http_referer, COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12' -- the email came in on April 12, 2012
GROUP BY 
    utm_source,
    utm_campaign,
    http_referer
ORDER BY 
    sessions DESC;

/*
Sounds like gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales.
Could you please calculate the conversion rate (CVR) from session to order ? Based on what we're paying for clicks,
we’ll need a CVR of at least 4% to make the numbers work. If we're much lower, we’ll need to reduce bids. If we’re higher, we can increase bids to drive more volume.
*/
SELECT 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
    LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'

/*
Based on your conversion rate analysis, we bid down gsearch nonbrand on 2012 04 15.
Can you pull gsearch nonbrand trended session volume, by week , to see if the bid changes have caused volume to drop at all? */

SELECT
    -- YEARWEEK(website_sessions.created_at) AS year_week,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-05-10'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'

GROUP BY
    YEARWEEK(website_sessions.created_at)

/*Could you pull conversion rates from session to order , by device type ?
If desktop performance is better than on mobile we may be able to bid up for desktop specifically to get more volume?*/
SELECT 
    website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions
    LEFT JOIN orders
        ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2015-05-11'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1;

/*After your device level analysis of conversion rates, we realized desktop was doing well, so we bid our gsearch
nonbrand desktop campaigns up on 2012 05 19. Could you pull weekly trends for both desktop and mobile so we can see the impact on volume?
You can use 2012 04 15 until the bid change as a baseline.*/

SELECT 
    -- YEARWEEK(website_sessions.created_at) AS year_week,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,

FROM website_sessions
WHERE website_sessions.created_at < '2012-06-09'
    AND website_sessions.created_at > '2012-04-15'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
    YEARWEEK(website_sessions.created_at)