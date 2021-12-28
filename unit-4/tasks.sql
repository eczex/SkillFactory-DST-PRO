-- Задания выполнял в локальной базе данных, скачанной отсюда: https://postgrespro.ru/docs/postgrespro/10/demodb-bookings-installation

select city as qty
from airports
group by city
having count(*) > 1;

select count(distinct status)
from flights;

select distinct status
from flights;

select count(*)
from flights
where status = 'Departed';

select count(*)
from seats
left join aircrafts a on seats.aircraft_code = a.aircraft_code
where model = 'Боинг 777-300';

select count(*)
from flights
where 1=1
-- and actual_departure > '2017-04-01 00:00:00.000000 +00:00'
and actual_arrival between '2017-04-01 00:00:00.000000 +00:00' and '2017-09-01 00:00:00.000000 +00:00'
and status = 'Arrived'
limit 100;

-- Задание 4.3

-- Вопрос 1. Сколько всего рейсов было отменено по данным базы?
select count(*)
from flights
where status = 'Cancelled';

-- Вопрос 2. Сколько самолетов моделей типа Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?
select *
from aircrafts;

select
       substr(a.model, 0, position(' ' in a.model)) as vendor,
       count(distinct a.model)
-- from flights as f
from aircrafts as a --on f.aircraft_code = a.aircraft_code
group by vendor
;

-- Вопрос 3. В какой части (частях) света находится больше аэропортов?
select
       distinct substr(timezone, 0, position('/' in timezone)) as world_part,
       count(*) over (partition by substr(timezone, 0, position('/' in timezone)))
from airports
-- order by substr(timezone, 0, position('/' in timezone))
-- limit 100
order by 2;

-- Вопрос 4. У какого рейса была самая большая задержка прибытия за все время сбора данных? Введите id рейса (flight_id).
select
       flight_id,
       max(actual_arrival - scheduled_arrival) as lag
from flights
where 1=1
and actual_arrival is not null
and scheduled_arrival is not null
group by flight_id
order by lag desc
limit 1;

-- Задание 4.4

-- Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?
select min(scheduled_departure)
from flights;


-- Вопрос 2. Сколько минут составляет запланированное время полета в самом длительном рейсе?
select EXTRACT(EPOCH from scheduled_arrival- scheduled_departure)/60 as diff
from flights
order by 1 desc
limit 1;


-- Вопрос 3. Между какими аэропортами пролегает самый длительный по времени запланированный рейс?
select
       scheduled_arrival- scheduled_departure as diff,
       departure_airport,
       arrival_airport
from flights
order by 1 desc
limit 1;


-- Вопрос 4. Сколько составляет средняя дальность полета среди всех самолетов в минутах?
-- Секунды округляются в меньшую сторону (отбрасываются до минут).
select avg(EXTRACT(EPOCH from scheduled_arrival- scheduled_departure)/60) as diff
from flights
order by 1 desc
limit 1;


-- Задание 4.5

-- Вопрос 1. Мест какого класса у SU9 больше всего?
select
    fare_conditions,
    count(*)
from seats
where aircraft_code = 'SU9'
group by fare_conditions
order by 2 desc
limit 1;


-- Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?
select min(total_amount) from bookings;


-- Вопрос 3. Какой номер места был у пассажира с id = 4313 788533?
select seat_no
from tickets
join boarding_passes bp on tickets.ticket_no = bp.ticket_no
where passenger_id = '4313 788533'

-- Задание 5.1

-- Вопрос 1. Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?
select count(*)
from flights
where arrival_airport in (
    select airport_code
    from airports
    where city = 'Анапа'
    )
and extract(year from actual_arrival) = 2017

-- Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?
select count(*)
from flights
where departure_airport in (
    select airport_code
    from airports
    where city = 'Анапа'
    )
and extract(year from actual_departure) = 2017
and extract(month from actual_arrival) in (1, 2, 12);

-- Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время.
select count(*)
from flights
where departure_airport in (
    select airport_code
    from airports
    where city = 'Анапа'
    )
and status = 'Cancelled';

-- Вопрос 4. Сколько рейсов из Анапы не летают в Москву?
select count( flight_no)
from flights
where departure_airport in (
    select airport_code
    from airports
    where city = 'Анапа'
    )
and arrival_airport not in (
    select airport_code
    from airports
    where city = 'Москва'
    )

-- Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?
select
       a.model,
       count(seats.seat_no)
from seats
join aircrafts a on seats.aircraft_code = a.aircraft_code
where seats.aircraft_code in (
    select distinct aircraft_code
    from flights
    where departure_airport in (
        select airport_code
        from airports
        where city = 'Анапа'
        )
    )
group by a.model
order by 2 desc
limit 1;


-- 6. Переходим к реальной аналитике
SELECT *
FROM flights
WHERE departure_airport = 'AAQ'
  AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  AND status not in ('Cancelled')

select count(*)
from bookings;

select count(*)
from tickets;

select count(*)
from ticket_flights;

select count(*)
from boarding_passes;

select count(distinct flight_no)
from flights
where departure_airport in (
    select airport_code
    from airports
    where city = 'Анапа'
    )
and extract(year from actual_departure) = 2017
and extract(month from actual_arrival) in (1, 2, 12);