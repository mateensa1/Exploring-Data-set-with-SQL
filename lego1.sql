use [Rebrickable]
1--Total number of parts per theme?

select theme_name ,sum(num_parts) as total_num_parts
from dbo.analytics_main
where parent_theme_name is not null
group by theme_name
order by 2 desc

2--Total number of parts per year?
select year ,sum(num_parts) as total_num_parts
from dbo.analytics_main
where parent_theme_name is not null
group by year
order by 2 desc

--3-How many sets were created in each century in the dataset
select century ,count(set_num) as total_set_num
from dbo.analytics_main
where parent_theme_name is not null
group by Century

--4 what percentage of sets ever release in the 21st century were trains themed 
;With CTE as
(
	select century,theme_name, count(set_num)as total_set_num
	from analytics_main
	where Century = '21st_century'
	group by Century,theme_name
)
select sum(total_set_num) as Total_train_sets,sum(percentage) as Total_train_sets_percentage 
from(
	select century,theme_name,total_set_num,sum(total_set_num) over() as total,CAST(1.00 * total_set_num/sum(total_set_num) over() as decimal(5,4))*100 as Percentage
	from CTE
	
	--order by 3 desc
	)m
where theme_name like '%train%'

--5 what was the popular them by year in terms of sets relsease in the 21st century
select year, theme_name, total_set_num
from (
	select year, theme_name, count(set_num) total_set_num, ROW_NUMBER() OVER (partition by year order by count(set_num) desc) rn
	from analytics_main
	where Century = '21st_Century'
		--and parent_theme_name is not null
	group by year, theme_name
)m
where rn = 1	
order by year desc

---6---
---What is the most produced color of lego ever in terms of quantity of parts?
select color_name, sum(quantity) as quantity_of_parts
from 
	(
		select
			inv.color_id, inv.inventory_id, inv.part_num, cast(inv.quantity as numeric) quantity, inv.is_spare, c.name as color_name, c.rgb, p.name as part_name, p.part_material, pc.name as category_name
		from inventory_parts inv
		inner join colors c
			on inv.color_id = c.id
		inner join parts p
			on inv.part_num = p.part_num
		inner join part_categories pc
			on part_cat_id = pc.id
	)main

group by color_name
order by 2 desc 