-- Проект выполнял, используя подключение skillfactory@84.201.134.129

create temp table fuel_consumption(
    model text,
    consumption float -- Tons/hour
);

-- Consumption information: http://newsruss.ru/doc/index.php/%D0%A0%D0%B0%D1%81%D1%85%D0%BE%D0%B4_%D1%82%D0%BE%D0%BF%D0%BB%D0%B8%D0%B2%D0%B0_%D1%81%D0%B0%D0%BC%D0%BE%D0%BB%D0%B5%D1%82%D0%B0#cite_note-98
insert into fuel_consumption
values ('Boeing 737-300', 2.400),
       ('Sukhoi Superjet-100', 1.700);

create temp table fuel_price_2017(
    month int,
    price int -- RUR/ton in Anapa
);

-- Fuel price information: https://favt.gov.ru/dejatelnost-ajeroporty-i-ajerodromy-ceny-na-aviagsm/?id=7329
insert into fuel_price_2017
values (1, 41435),
       (2, 39553),
       (12, 47101);

select
    f.flight_id,
    f.departure_airport,
    da.longitude as departure_longitude,
    da.latitude as departure_latitude,
    f.arrival_airport,
    aa.longitude as arrival_longitude,
    aa.latitude as arrival_latitude,
    a.model,
    fc.consumption,
    extract(month from f.scheduled_departure) as month,
    fp.price,
    extract(epoch from (f.actual_arrival - f.actual_departure))/60/60 as flight_duration_in_hours,
    fp.price * (extract(epoch from (f.actual_arrival - f.actual_departure))/60/60) * fc.consumption * 1.18 as spent, --
    sum(tf.amount) as earned,
    sum(tf.amount) - (fp.price * (extract(epoch from (f.actual_arrival - f.actual_departure))/60/60) * fc.consumption) as profit
from dst_project.flights as f
    left join dst_project.airports da on da.airport_code = f.departure_airport
    left join dst_project.airports aa on aa.airport_code = f.arrival_airport
    left join dst_project.aircrafts as a on a.aircraft_code = f.aircraft_code
    join dst_project.ticket_flights as tf on f.flight_id = tf.flight_id
    left join fuel_consumption as fc on a.model = fc.model
    left join fuel_price_2017 as fp on fp.month = extract(month from f.scheduled_departure)
where 1=1
  and departure_airport = 'AAQ'
  and (date_trunc('month', f.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  and status not in ('Cancelled')
group by
    f.flight_id,
    f.departure_airport,
    da.longitude,
    da.latitude,
    f.arrival_airport,
    aa.longitude,
    aa.latitude,
    a.model,
    fc.consumption,
    fp.price,
    flight_duration_in_hours
having
    sum(tf.amount) > 0 -- We are not interested in flights with no tickets
order by 15;