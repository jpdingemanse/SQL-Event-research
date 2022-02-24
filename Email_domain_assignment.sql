WITH cte_email_domains (account_id, event, email_domain, full_email, number_of_users, annual_plan, total_monetary, joined_participants, active_participants, 
                        avg_participant_event, avg_active_participant_event, activation_30_perc, activation_90_perc) AS (
    SELECT 
  		a.account_id,
        e.event_id,
  		substr(email, instr(email, '@') + 1),
  		a.email,
        s.users,                  
  		s.plan,
 		price,
  		e.joined_participants,
  		e.active_participants,
  		Round((Select joined_participants from (select AVG(joined_participants) as joined_participants, substr(email, instr(email, '@') + 1) as domain from accounts a inner join events e on a.account_id  = e.account_id group by domain) Where domain = substr(email, instr(email, '@') + 1)), 2),
  		Round((Select active_participants from(select AVG(active_participants) as active_participants, substr(email, instr(email, '@') + 1) as domain from accounts a inner join events e on a.account_id  = e.account_id group by domain) Where domain = substr(email, instr(email, '@') + 1)), 2),
         -- select all events happening within 30 days from subscription 
  		 100 * (select activation from 
                	-- count of events based on domains
               		(select substr(email, instr(email, '@') + 1) as domain, count(*) as activation from accounts a 
                      	inner join events e on a.account_id  = e.account_id 
                     		-- add 30 days to the subscription date to check with event date
                          	where DATE(a.date_subscription,'+30 days') > e.date 
                     		--events may not be happened before subscription date
                          	and a.date_subscription < e.date 
                     		-- get the results per domain
                          	group by domain) 
                		Where domain = substr(email, instr(email, '@') + 1)) 
                 --devide with total events for the same domain
                	/ 
                 -- get the number of all events from the same domain
                (select total from 
                 	(select substr(email, instr(email, '@') + 1) as domain, count(*) as total  from accounts a 
                     	inner join events e on a.account_id  = e.account_id 
                     		group by domain) 
                		Where domain = substr(email, instr(email, '@') + 1)),
        -- select all events happening within 90 days from subscription 
  		 100 * (select activation from 
                	-- count of events based on domains
               		(select substr(email, instr(email, '@') + 1) as domain, count(*) as activation from accounts a 
                      	inner join events e on a.account_id  = e.account_id 
                     		-- add 30 days to the subscription date to check with event date
                          	where DATE(a.date_subscription,'+90 days') > e.date 
                     		--events may not be happened before subscription date
                          	and a.date_subscription < e.date 
                     		-- get the results per domain
                          	group by domain) 
                		Where domain = substr(email, instr(email, '@') + 1)) 
                 --devide with total events for the same domain
                	/ 
                 -- get the number of all events from the same domain
                (select total from 
                 	(select substr(email, instr(email, '@') + 1) as domain, count(*) as total  from accounts a 
                     	inner join events e on a.account_id  = e.account_id 
                     		group by domain) 
                		Where domain = substr(email, instr(email, '@') + 1))	
   FROM    
        accounts a
    INNER JOIN subscriptions s ON s.account_id = a.account_id
    INNER JOIN events e ON e.account_id = a.account_id
    GROUP BY a.account_id, event_id, subscription_id
)

selecT * from cte_email_domains order by event


--select count(*) from cte_email_domains
