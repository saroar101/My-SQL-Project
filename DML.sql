--------------------------SQL Project------------------------
-------------------Name : Bus Booking System ----------------


------------------DML Part------------------


------------Inserting sample data into Buses table-------------

USE BusBooking
INSERT INTO Buses (bus_id, bus_name, total_seats, bus_type, status)
VALUES 
(1, 'Hanif Enterprise', 40, 'AC', 'Active'),
(2, 'Hanif Enterprise', 50, 'Non-AC', 'Active'),
(3, 'Nikot Express', 40, 'AC', 'Active'),
(4, 'Nikot Express', 50, 'Non-AC', 'Active'),
(5, 'Ena Poribahan', 40, 'AC', 'Active'),
(6, 'Ena Poribahan', 50, 'Non-AC', 'Active'),
(7, 'Sent Martin Express', 40, 'AC', 'Active');


----------Inserting sample data into Routes table---------
-
INSERT INTO Routes (route_id, origin, destination, distance, travel_time)
VALUES 
(1, 'Naogaon', 'Dhaka', 350, '06:00:00'),
(2, 'Dhaka', 'Naogaon', 350, '09:00:00'),
(3, 'Chittagong', 'Naogaon', 550, '05:00:00'),
(4, 'Naogaon', 'Chittagong', 550, '04:30:00'),
(5, 'Naogaon', 'Sylet', 400, '02:00:00'),
(6, 'Sylet', 'Naogaon', 400, '03:00:00');


-----------Inserting sample data into Schedules table------------

INSERT INTO Schedules (schedule_id, bus_id, route_id, departure_time, arrival_time)
VALUES
(1, 1, 1, '2024-11-26 08:00:00', '2024-11-26 14:00:00'),
(2, 2, 1, '2024-11-26 09:00:00', '2024-11-26 15:00:00'),
(3, 3, 2, '2024-11-26 07:30:00', '2024-11-26 16:30:00'),
(4, 4, 3, '2024-11-26 06:00:00', '2024-11-26 11:00:00'),
(5, 5, 4, '2024-11-26 10:00:00', '2024-11-26 14:30:00'),
(6, 6, 5, '2024-11-26 12:00:00', '2024-11-26 14:00:00'),
(7, 7, 6, '2024-11-26 15:00:00', '2024-11-26 18:00:00');


-------------Booking a ticket (Insert into Bookings table)------------

INSERT INTO Bookings (booking_id, schedule_id, seats_booked, booking_date, total_amount)
VALUES 
(1, 1, 2, GETDATE(), 700.00),
(2, 2, 3, GETDATE(), 1050.00),
(3, 3, 1, GETDATE(), 350.00),
(4, 4, 5, GETDATE(), 1750.00),
(5, 5, 2, GETDATE(), 700.00),
(6, 6, 4, GETDATE(), 1400.00),
(7, 7, 6, GETDATE(), 2100.00);


------------Inserting payment details into Payments table-----------

INSERT INTO Payments (booking_id,payment_id, payment_date, amount_paid, payment_status, payment_method)
VALUES
(1,1, GETDATE(), 2000.00, 'Paid', 'Credit Card'),
(2,2, GETDATE(), 1500.00, 'Paid', 'Debit Card'),
(3,3, GETDATE(), 2000.00, 'Paid', 'Credit Card'),
(4,4, GETDATE(), 1500.00, 'Paid', 'Debit Card'),
(5,5, GETDATE(), 2000.00, 'Paid', 'Credit Card'),
(6,6, GETDATE(), 2000.00, 'Paid', 'Credit Card'),
(7,7, GETDATE(), 1500.00, 'Paid', 'Debit Card');



 --------View all active buses with routes from Naogaon to Dhaka--------

SELECT 
    s.schedule_id, 
    s.bus_id, 
    r.origin, 
    r.destination, 
    r.distance, 
    r.travel_time, 
    s.departure_time, 
    s.arrival_time
FROM 
    Schedules s
JOIN 
    Routes r ON s.route_id = r.route_id
WHERE 
    (r.origin = 'Naogaon' AND r.destination = 'Dhaka')
    OR (r.origin = 'Naogaon' AND r.destination = 'Dhaka')
    AND s.departure_time > GETDATE();  



 ---------View all active buses with routes from  Dhaka to Naogaon--------

SELECT 
    s.schedule_id, 
    s.bus_id, 
    r.origin, 
    r.destination, 
    r.distance, 
    r.travel_time, 
    s.departure_time, 
    s.arrival_time
FROM 
    Schedules s
JOIN 
    Routes r ON s.route_id = r.route_id
WHERE 
    (r.origin = 'Dhaka' AND r.destination = 'Naogaon')
    OR (r.origin = 'Dhaka' AND r.destination = 'Naogaon')
    AND s.departure_time > GETDATE();  



 --------- View all active buses with routes from Naogaon  to Chittagong---------

SELECT 
    s.schedule_id, 
    s.bus_id, 
    r.origin, 
    r.destination, 
    r.distance, 
    r.travel_time, 
    s.departure_time, 
    s.arrival_time
FROM 
    Schedules s
JOIN 
    Routes r ON s.route_id = r.route_id
WHERE 
    (r.origin = 'Naogaon' AND r.destination = 'Chittagong')
    OR (r.origin = 'Naogaon' AND r.destination = 'Chittagong')
    AND s.departure_time > GETDATE();  



--------View all active buses with routes from Chittagong to Naogaon----------  

SELECT 
    s.schedule_id, 
    s.bus_id, 
    r.origin, 
    r.destination, 
    r.distance, 
    r.travel_time, 
    s.departure_time, 
    s.arrival_time
FROM 
    Schedules s
JOIN 
    Routes r ON s.route_id = r.route_id
WHERE 
    (r.origin = 'Chittagong' AND r.destination = 'Naogaon')
    OR (r.origin = 'Chittagong' AND r.destination = 'Naogaon')
    AND s.departure_time > GETDATE();  





 -------View all active buses with routes from Naogaon to Sylet--------

SELECT 
    s.schedule_id, 
    s.bus_id, 
    r.origin, 
    r.destination, 
    r.distance, 
    r.travel_time, 
    s.departure_time, 
    s.arrival_time
FROM 
    Schedules s
JOIN 
    Routes r ON s.route_id = r.route_id
WHERE 
    (r.origin = 'Naogaon' AND r.destination = 'Sylet')
    OR (r.origin = 'Sylet' AND r.destination = 'Naogaon')
    AND s.departure_time > GETDATE();  



--------View all active buses with routes from Sylet to Naogaon --------
SELECT 
    s.schedule_id, 
    s.bus_id, 
    r.origin, 
    r.destination, 
    r.distance, 
    r.travel_time, 
    s.departure_time, 
    s.arrival_time
FROM 
    Schedules s
JOIN 
    Routes r ON s.route_id = r.route_id
WHERE 
    (r.origin = 'Sylet' AND r.destination = 'Naogaon')
    OR (r.origin = 'Sylet' AND r.destination = 'Naogaon')
    AND s.departure_time > GETDATE();  


----------Check seat availability for a specific schedule-----------

SELECT b.bus_name, 
       b.total_seats, 
       ISNULL(SUM(booking.seats_booked), 0) AS booked_seats, 
       (b.total_seats - ISNULL(SUM(booking.seats_booked), 0)) AS available_seats
FROM Buses b
LEFT JOIN Schedules s ON b.bus_id = s.bus_id
LEFT JOIN Bookings booking ON s.schedule_id = booking.schedule_id
WHERE s.schedule_id = 1
GROUP BY b.bus_id, b.bus_name, b.total_seats;



----------View payment status for a booking-------------

SELECT p.payment_status, p.amount_paid, p.payment_date, p.payment_method
FROM Payments p
JOIN Bookings b ON p.booking_id = b.booking_id
WHERE b.booking_id = 1; 



-- ----------  Queries to Test----------
------Get schedules for a specific route-----

SELECT * FROM GetSchedulesByRoute('Naogaon', 'Dhaka');
SELECT * FROM GetSchedulesByRoute('Naogaon', 'Chitagong');
SELECT * FROM GetSchedulesByRoute('Naogaon', 'sylet');
SELECT * FROM GetSchedulesByRoute('Chitagong', 'Naogaon');


------------ Calculate fare for 450 km----------

SELECT dbo.CalculateFare(450);

----------Check bus status----------

SELECT * FROM Buses;

--------- Check bookings and payments-------

SELECT * FROM Bookings;
SELECT * FROM Payments;
