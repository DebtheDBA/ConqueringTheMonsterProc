CREATE EVENT SESSION [MonsterProc]
ON SERVER
    ADD EVENT sqlserver.error_reported
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.rpc_completed
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.rpc_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.sp_statement_completed
    (SET collect_object_name = (1)
     ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.query_plan_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.sp_statement_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.sql_batch_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.sql_statement_completed
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.query_plan_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    ),
    ADD EVENT sqlserver.sql_statement_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE ([sqlserver].[database_name] = N'AutoDealershipDemo_Summit2023')
    )
    ADD TARGET package0.event_file
    (SET FILENAME = N'C:\GitRepo\ConqueringtheMonsterProc\ExtendedEvents\MonsterProc.xel')
WITH
(
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
);
GO


