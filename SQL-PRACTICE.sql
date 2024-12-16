-- USING HOSPITAL DB:

/* 1. Show all of the patients grouped into weight groups.
Show the total amount of patients in each weight group.
Order the list by the weight group decending.
For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc. */

select floor(weight/10)*10 as weight_group, count(*) as total
from patients
group by weight_group
order by weight_group desc;

/* 2. Show patient_id, first_name, last_name, and attending doctor's specialty.
Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'. */

select a.patient_id, p.first_name, p.last_name, d.specialty
from admissions a
join patients p on a.patient_id = p.patient_id
join doctors d on a.attending_doctor_id = d.doctor_id
where a.diagnosis = 'Epilepsy' and d.first_name = 'Lisa';

/* 3. All patients who have gone through admissions can see their medical documents on our site. 
Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.

The password must be the following, in order:
1. patient_id
2. the numerical length of patient's last_name
3. year of patient's birth_date */

select distinct(a.patient_id) as patient_id, concat(a.patient_id, len(p.last_name), year(p.birth_date))
from admissions a
join patients p on a.patient_id = p.patient_id;

/* 4. Each admission costs $50 for patients without insurance, and $10 for patients with insurance. 
All patients with an even patient_id have insurance.
Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. 
Add up the admission_total cost for each has_insurance group. */

select
case
	when patient_id%2 = 0 then 'Yes'
    ELSE 'No'
END as has_insurance,
sum(case
	when patient_id%2 = 0 then 10
    else 50
end) as admission_total
from admissions
group by has_insurance;

-- 5. Show the provinces that has more patients identified as 'M' than 'F'.

with CTE as (select province_name, pn.province_id,
  sum(case
      when gender = 'M' then 1
      else 0
      end) as m_count,
  sum(case
      when gender = 'F' then 1
      else 0
      end) as f_count
from patients p
right join province_names pn
on p.province_id = pn.province_id
group by pn.province_id)

select province_name from CTE
where m_count > f_count;

/* 6. For each day display the total amount of admissions on that day. 
Display the amount changed from the previous date. */

select admission_date, count(*) as adm_count, 
count(*) - lag(count(*)) over(order by admission_date) as adm_diff
from admissions
group by admission_date
order by admission_date;

/* 7. We need a breakdown for the total amount of admissions each doctor has started each year. 
Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year. */

select doctor_id, concat(first_name, ' ', last_name) as doctor_full_name,
specialty,
year(admission_date), count(*) as total_admissions
from admissions a
right join doctors d
on d.doctor_id = a.attending_doctor_id
group by doctor_id, year(admission_date)
order by doctor_id, year(admission_date);

-- USING NORTHWIND STORE DB:

/* 1. Show the city, company_name, contact_name from the customers and suppliers table merged together.
Create a column which contains 'customers' or 'suppliers' depending on the table it came from. */

select city, company_name, contact_name, 
'Customers' as designation
from customers
union
select city, company_name, contact_name,
'Suppliers' from suppliers;

/* 2. Show the employee's first_name and last_name, a "num_orders" column with a count of the orders taken, 
and a column called "Shipped" that displays "On Time" if the order shipped_date is less or equal to the required_date, 
"Late" if the order shipped late.

Order by employee last_name, then by first_name, and then descending by number of orders. */

select first_name, last_name, count(*) as num_orders,
case
	when shipped_date <= required_date then 'On Time'
    else 'Late'
   end as Shipped
from employees e
left join orders o on e.employee_id = o.employee_id
group by e.employee_id, Shipped
order by last_name, first_name, num_orders desc;

/* 3. Show how much money the company lost due to giving discounts each year, 
ordering the years from most recent to least recent. Round to 2 decimal places. */

with CTE as (select year(order_date) as order_year, 
case
	when discount != 0 then (1 - discount)*unit_price*quantity
    else unit_price*quantity
   end as price,
unit_price*quantity as max_price
from orders o
join order_details od 
on o.order_id = od.order_id
join products p 
on od.product_id = p.product_id)

select order_year, round(sum(max_price - price), 2) as amt_lost
from CTE
group by order_year
order by order_year desc;


