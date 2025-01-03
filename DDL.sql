
-------------------------------------SQL Project-------------------------
-----------------------------Name : Bus Booking System ------------------
--------------------------------------DML Part---------------------------
 

GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BusBooking')
BEGIN
    DROP DATABASE BusBooking;
END
GO
CREATE DATABASE BusBooking
ON PRIMARY (
    NAME = 'BusBooking_DATA',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SHAROAR\MSSQL\DATA\BusBooking_DATA.mdf',
    SIZE = 40MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 10%
)
LOG ON (
    NAME = 'BusBooking_LOG',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SHAROAR\MSSQL\DATA\BusBooking_LOG.ldf',
    SIZE = 10MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 10%
);
GO


------------------DDL Part-----------------

----  Create Tables

USE BusBooking;
CREATE TABLE Buses (
    bus_id INT PRIMARY KEY,
    bus_name VARCHAR(100),
    total_seats INT,
    bus_type VARCHAR(50),
    status VARCHAR(20) -- e.g., Active, Full
);

CREATE TABLE Routes (
    route_id INT PRIMARY KEY,
    origin VARCHAR(100),
    destination VARCHAR(100),
    distance INT, -- in kilometers
    travel_time TIME
);

CREATE TABLE Schedules (
    schedule_id INT PRIMARY KEY,
    bus_id INT,
    route_id INT,
    departure_time DATETIME,
    arrival_time DATETIME,
    FOREIGN KEY (bus_id) REFERENCES Buses(bus_id),
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    schedule_id INT,
    seats_booked INT,
    booking_date DATETIME,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (schedule_id) REFERENCES Schedules(schedule_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    booking_id INT,
    payment_date DATETIME,
    amount_paid DECIMAL(10, 2),
    payment_status VARCHAR(20),
	payment_method VARCHAR(20),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);



----------------Triggers----------------

CREATE TRIGGER after_booking_insert
ON Bookings
AFTER INSERT
AS
BEGIN
    DECLARE @schedule_id INT, @bus_id INT, @total_seats INT, @booked_seats INT;

    -- Get the schedule_id from the inserted data
    SELECT @schedule_id = schedule_id FROM INSERTED;

    -- Get the total seats of the bus
    SELECT @bus_id = s.bus_id, @total_seats = b.total_seats
    FROM Buses b
    JOIN Schedules s ON b.bus_id = s.bus_id
    WHERE s.schedule_id = @schedule_id;

    -- Get the total booked seats for the schedule
    SELECT @booked_seats = ISNULL(SUM(bk.seats_booked), 0)
    FROM Bookings bk
    WHERE bk.schedule_id = @schedule_id;

    -- Update bus status if fully booked
    IF @booked_seats >= @total_seats
    BEGIN
        UPDATE Buses
        SET status = 'Full'
        WHERE bus_id = @bus_id;
    END
END;



---------- After UPDATE Trigger: Log updates----------

CREATE TRIGGER after_booking_update
ON Bookings
AFTER UPDATE
AS
BEGIN
    INSERT INTO Payments (payment_id, booking_id, payment_date, amount_paid, payment_status)
    SELECT NULL, i.booking_id, GETDATE(), i.total_amount, 'Updated'
    FROM INSERTED i;
END;


---------- After DELETE Trigger: Log cancellations------------

CREATE TRIGGER after_booking_delete
ON Bookings
AFTER DELETE
AS
BEGIN
    INSERT INTO Payments (payment_id, booking_id, payment_date, amount_paid, payment_status)
    SELECT NULL, d.booking_id, GETDATE(), d.total_amount, 'Cancelled'
    FROM DELETED d;
END;


---------------- Table-Valued Function---------------

CREATE FUNCTION GetSchedulesByRoute(@origin VARCHAR(100), @destination VARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT s.schedule_id, b.bus_name, s.departure_time, s.arrival_time
    FROM Schedules s
    JOIN Routes r ON s.route_id = r.route_id
    JOIN Buses b ON s.bus_id = b.bus_id
    WHERE r.origin = @origin AND r.destination = @destination
);



--------------  Scalar-Valued Function------------

CREATE FUNCTION CalculateFare(@distance INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @distance * 1.5; -- Assume fare is 1.5 per km
END;


-------------multi statement table-------------

CREATE FUNCTION GetBookingDetails()
RETURNS @BookingDetails TABLE (
    booking_id INT,
    bus_name VARCHAR(100),
    origin VARCHAR(100),
    destination VARCHAR(100),
    seats_booked INT,
    total_amount DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert into the table variable
    INSERT INTO @BookingDetails (booking_id, bus_name, origin, destination, seats_booked, total_amount)
    SELECT 
        b.booking_id,
        bus.bus_name,
        route.origin,
        route.destination,
        b.seats_booked,
        b.total_amount
    FROM 
        Bookings b
    JOIN Schedules s ON b.schedule_id = s.schedule_id
    JOIN Buses bus ON s.bus_id = bus.bus_id
    JOIN Routes route ON s.route_id = route.route_id;

    -- Return the result
    RETURN;
END;
GO

SELECT * FROM dbo.GetBookingDetails();


---------------Merge Table------------


CREATE TABLE BookingDetails (
    detail_id INT PRIMARY KEY IDENTITY(1,1), 
    bus_name VARCHAR(100),
    origin VARCHAR(100),
    destination VARCHAR(100),
    departure_time DATETIME,
    arrival_time DATETIME,
    seats_booked INT,
    total_amount DECIMAL(10, 2)
);


WITH BookingSummary AS (
    SELECT 
        r.route_id,
        r.origin,
        r.destination,
        COUNT(bk.booking_id) AS total_bookings,
        SUM(bk.seats_booked) AS total_seats_booked,
        SUM(bk.total_amount) AS total_revenue
    FROM 
        Routes r
    JOIN 
        Schedules s ON r.route_id = s.route_id
    JOIN 
        Bookings bk ON s.schedule_id = bk.schedule_id
    GROUP BY 
        r.route_id, r.origin, r.destination
)
SELECT 
    route_id,
    origin,
    destination,
    total_bookings,
    total_seats_booked,
    total_revenue
FROM 
    BookingSummary
ORDER BY 
    total_revenue DESC;


--------------CASE FUNCTION------------

CREATE VIEW BookingStatusView AS
SELECT 
    bk.booking_id,
    bk.schedule_id,
    bk.seats_booked,
    bk.total_amount,
    bk.booking_date,
    CASE 
        WHEN bk.seats_booked <= 2 THEN 'Small Booking'
        WHEN bk.seats_booked > 2 AND bk.seats_booked <= 20 THEN 'Medium Booking'
        ELSE 'Large Booking'
    END AS BookingSize,
    CASE 
        WHEN bk.total_amount >= 1500 THEN 'High Value'
        WHEN bk.total_amount BETWEEN 1000 AND 999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS BookingValueCategory
FROM 
    Bookings bk;





---------------------Procedure ---------------------

----------Insert Procedure-----------

CREATE PROCEDURE InsertBooking
    @schedule_id INT,
    @seats_booked INT,
    @booking_date DATETIME,
    @total_amount DECIMAL(10, 2),
    @new_booking_id INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Bookings (schedule_id, seats_booked, booking_date, total_amount)
        VALUES (@schedule_id, @seats_booked, @booking_date, @total_amount);

        SET @new_booking_id = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


----------------Update Procedure------------------

CREATE PROCEDURE UpdateBooking
    @booking_id INT,
    @seats_booked INT,
    @total_amount DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Bookings
        SET seats_booked = @seats_booked,
            total_amount = @total_amount
        WHERE booking_id = @booking_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


---------------Delete Procedure-----------


CREATE PROCEDURE DeleteBooking
    @booking_id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Bookings
        WHERE booking_id = @booking_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;


