-- first stored procedure, functions and triggers 
-- later we can add some ai agent to this programming objects to make it more intelligent and automated I gueees


-- INDEXING
-- primary key are automaticaly idexes
-- it is good practice to add indexes on foreign keys and other columns that are frequently used in queries to improve performance.

-- STORED PROCEDURES
-- Stored procedures are precompiled SQL statements that can be executed multiple times with different parameters. 
-- They can be used to encapsulate complex logic and improve performance by reducing the amount of data sent over the network.
-- you should always use stored procedures for data manipulation (insert, update, delete) instead of direct SQL statements in our application code.
-- you should drop and recreate stored procedures 



if OBJECT_ID('dbo.procRecordEvent', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procRecordEvent;

if OBJECT_ID('dbo.trgUpdateRoomStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trgUpdateRoomStatus; 

if OBJECT_ID('dbo.procUpdateRoomStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.procUpdateRoomStatus;

GO

CREATE OR ALTER PROCEDURE procRecordEvent
    @MacAddress nvarchar(17), -- e.g. '00:1A:7D:DA:71:13'
    @EventType nvarchar(5) -- 'Enter' or 'Exit'
AS
BEGIN

    declare @SensorID int;

    select @SensorID = SensorID from Sensor where MacAddress = @MacAddress;

    INSERT INTO SensorLog (SensorID, EventType, ExitDateTime)
    --VALUES (@SensorID, @EventType, GETDATE() AT TIME ZONE 'Eastern Standard Time');
    values (@SensorID, @EventType, SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time')
END;
GO

/*
select * from SensorLog where SensorID = 2 order by EventDateTime desc;
select * from Room;
execute procRecordEvent 1, 'Enter';
*/

GO

create or alter PROCEDURE procUpdateRoomStatus
    @RoomID int, 
    @EventType NVARCHAR(5)
AS
BEGIN
    update Room
    set CurrentStatus = @EventType
    where RoomID = @RoomID

end;

go

create or alter trigger trgUpdateRoomStatus
on SensorLog
after insert
as
begin

    declare @EventType nvarchar(5), @RoomID int;
    select @EventType = I.EventType, @RoomID = S.RoomID
    from inserted I inner join Sensor S 
        on I.SensorID = S.SensorID;


    -- trigger action
    if (@EventType = 'Enter')
    begin
    execute procUpdateRoomStatus @RoomID, 'Enter';
        --update Room
        --set CurrentStatus = 'Occupied'
       -- where RoomID = @RoomID
    end
    else if (@EventType = 'Exit')
    begin
    execute procUpdateRoomStatus @RoomID, 'Exit';
       -- update Room
        --set CurrentStatus = 'Available'
        --where RoomID = @RoomID
    end

end;

/*
GO

create or alter PROCEDURE procUpdateRoomStatus
    @RoomID int, 
    @EventType NVARCHAR(5)
AS
BEGIN
    update Room
    set CurrentStatus = @EventType
    where RoomID = @RoomID

end;
*/
-- execute procUpdateRoomStatus 1, 'Enter';
