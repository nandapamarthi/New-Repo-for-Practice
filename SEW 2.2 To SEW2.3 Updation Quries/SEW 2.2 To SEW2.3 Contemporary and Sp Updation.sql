/****** Object:  Table [dbo].[ContemporaryChannelData]    Script Date: 28-Mar-15 17:34:07 ******/

Drop Table ContemporaryChannelData

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ContemporaryChannelData](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ChannelDataId] [int] NOT NULL,
	[ChannelId] [int] NOT NULL,
	[ChannelName] [varchar](50) NULL,
	[ChannelValue] [varchar](50) NULL,
	[Units] [varchar](50) NULL,
	[ChannelDataLogTime] [datetime] NULL,
	[PcbLimit] [varchar](50) NULL,
	[StationId] [int] NULL,
	[PreviousValueId] [int] NULL,
	[Active] [bit] NULL,
	[Minimum] [decimal](10, 2) NULL,
	[Maximum] [decimal](10, 2) NULL,
	[Average] [decimal](10, 2) NULL,
 CONSTRAINT [PK_ContemporaryChannelData] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

/****** Object:  StoredProcedure [dbo].[InsertOrUpdateContemporaryChannelData]    Script Date: 28-Mar-15 17:34:07 ******/

Drop Procedure InsertOrUpdateContemporaryChannelData

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[InsertOrUpdateContemporaryChannelData]
@channelId int,
@channelName varchar(100),
@channelValue decimal(10,2),
@chnlUnits varchar(10),
@dateTime datetime,
@PCBStandard varchar(100),
@stationId int
AS
DECLARE @channelDataId int;
DECLARE @count int;
DECLARE @previousChnlId int
DECLARE @min decimal(10,2);
DECLARE @max decimal(10,2);
DECLARE @avg decimal(10,2);
BEGIN
	SET @channelDataId = (SELECT MAX(Id) FROM ChannelData WHERE ChannelId = @ChannelId)	
	SET @count = (SELECT COUNT(*) FROM [ContemporaryChannelData] WHERE [ChannelId]= @ChannelId);
	SET @min=(SELECT MIN(CONVERT(DECIMAL(10,2),convert(varchar(100),DECRYPTBYPASSPHRASE('bccb9c79-81c2-41c4-b7b6-49ef2587da93', ChannelValue)))) FROM ChannelData WHERE ChannelId = @ChannelId AND ChannelDataLogTime>= (select DateAdd(hour,-1,@dateTime)));
	SET @max=(SELECT MAX(CONVERT(DECIMAL(10,2),convert(varchar(100),DECRYPTBYPASSPHRASE('bccb9c79-81c2-41c4-b7b6-49ef2587da93', ChannelValue)))) FROM ChannelData WHERE ChannelId = @ChannelId AND ChannelDataLogTime>= (select DateAdd(hour,-1,@dateTime)));
	SET @avg=(SELECT AVG(CONVERT(DECIMAL(10,2),convert(varchar(100),DECRYPTBYPASSPHRASE('bccb9c79-81c2-41c4-b7b6-49ef2587da93', ChannelValue)))) FROM ChannelData WHERE ChannelId = @ChannelId AND ChannelDataLogTime>= (select DateAdd(hour,-1,@dateTime)));
	if(@count)= 0
		BEGIN			
			INSERT INTO [ContemporaryChannelData]
						([ChannelDataId]
						,[ChannelId]
						,[ChannelName]
						,[ChannelValue]
						,[Units]
						,[ChannelDataLogTime]
						,[PcbLimit]
						,[StationId]						
						,[Active]
						,[Minimum]
						,[Maximum]
						,[Average])
					VALUES
						(@channelDataId
						,@channelId
						,@channelName
						,@channelValue
						,@chnlUnits
						,@dateTime
						,@PCBStandard
						,@stationId          
						,1
						,@min
						,@max
						,@avg)						
		END		
	ELSE
		BEGIN
			SET @previousChnlId = (SELECT [ChannelDataId] FROM [ContemporaryChannelData] WHERE [ChannelId] = @channelId)
			SET @min=(SELECT MIN(CONVERT(DECIMAL(10,2),convert(varchar(100),DECRYPTBYPASSPHRASE('bccb9c79-81c2-41c4-b7b6-49ef2587da93', ChannelValue)))) FROM ChannelData WHERE ChannelId = @ChannelId AND ChannelDataLogTime>= (select DateAdd(hour,-1,@dateTime)));
			SET @max=(SELECT MAX(CONVERT(DECIMAL(10,2),convert(varchar(100),DECRYPTBYPASSPHRASE('bccb9c79-81c2-41c4-b7b6-49ef2587da93', ChannelValue)))) FROM ChannelData WHERE ChannelId = @ChannelId AND ChannelDataLogTime>= (select DateAdd(hour,-1,@dateTime)));
			SET @avg=(SELECT AVG(CONVERT(DECIMAL(10,2),convert(varchar(100),DECRYPTBYPASSPHRASE('bccb9c79-81c2-41c4-b7b6-49ef2587da93', ChannelValue)))) FROM ChannelData WHERE ChannelId = @ChannelId AND ChannelDataLogTime>= (select DateAdd(hour,-1,@dateTime)));
			UPDATE [ContemporaryChannelData]	
			   SET [ChannelDataId] = @channelDataId
				  ,[ChannelId] = @channelId     
				  ,[ChannelValue] = @channelValue 
				  ,[Units] = @chnlUnits
				  ,[ChannelDataLogTime] = @dateTime
				  ,[PcbLimit] = @PCBStandard   
				  ,[PreviousValueId] = @previousChnlId 
				  ,[Minimum] =  @min
				  ,[Maximum] = @max
				  ,[Average] = @avg
			 WHERE [ChannelId] = @channelId
		END
END