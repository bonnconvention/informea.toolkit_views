-- Meetings
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings` AS
    SELECT
        a.uuid as id,
        LOWER(instr_name.title) AS treaty,
        CONCAT('http://eurobats.eaudeweb.ro/node/', a.nid) as url,
        b.field_meeting_start_value as `start`,
        c.field_meeting_end_value as `end`,
        NULL as repetition,
        LOWER(e.name) as `kind`,
        LOWER(g.name) as `type`,
        NULL as `access`,
        LOWER(i.name) as `status`,
        NULL as imageUrl,
        NULL as imageCopyright,
        j.field_meeting_location_value as `location`,
        k.field_meeting_city_value as `city`,
        n.field_country_iso2_value as `country`,
        o.field_meeting_latitude_value as `latitude`,
        p.field_meeting_longitude_value as `longitude`,
        FROM_UNIXTIME(a.changed, '%Y-%m-%d %H:%i:%s') as updated
    FROM node a
    INNER JOIN field_data_field_meeting_instrument instr ON a.nid = instr.entity_id
    LEFT JOIN node instr_name ON instr.field_meeting_instrument_target_id = instr_name.nid
    INNER JOIN field_data_field_meeting_start b ON a.nid = b.entity_id
    LEFT JOIN field_data_field_meeting_end c ON a.nid = c.entity_id
    LEFT JOIN field_data_field_meeting_kind d ON a.nid = d.entity_id
    LEFT JOIN taxonomy_term_data e ON d.field_meeting_kind_tid = e.tid
    INNER JOIN field_data_field_meeting_type f ON a.nid = f.entity_id
    INNER JOIN taxonomy_term_data g ON f.field_meeting_type_tid = g.tid
    LEFT JOIN field_data_field_meeting_status h ON a.nid = h.entity_id
    LEFT JOIN taxonomy_term_data i ON h.field_meeting_status_tid = i.tid
    LEFT JOIN field_revision_field_meeting_location j ON a.nid = j.entity_id
    LEFT JOIN field_data_field_meeting_city k ON a.nid = k.entity_id
    INNER JOIN field_data_field_meeting_country m ON a.nid = m.entity_id
    INNER JOIN field_data_field_country_iso2 n ON m.field_meeting_country_target_id = n.entity_id
    LEFT JOIN field_data_field_meeting_latitude o ON a.nid = o.entity_id
    LEFT JOIN field_data_field_meeting_longitude p ON a.nid = o.entity_id
    WHERE a.`type` = 'meeting'
        AND LOWER(g.name) IN ('mop', 'cop')
        AND LOWER(instr_name.title) IN ('eurobats');

--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings_description` AS
    SELECT
        CONCAT(a.uuid, '-en') as id,
        a.uuid as meeting_id,
        'en' as `language`,
        b.field_meeting_description_value as description
    FROM node a
    INNER JOIN field_data_field_meeting_description b ON a.nid = b.entity_id;


CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings_title` AS
    SELECT
        CONCAT(a.uuid, '-en') as id,
        a.uuid as meeting_id,
        'en' as 'language',
        a.title
    FROM node a WHERE a.`type` = 'meeting';

-- DECISIONS

-- Create a support view with COP meetings and their decision IDs
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_cop_documents` AS
    SELECT
        h.entity_id AS id_document,
        a.uuid AS id_meeting
    FROM
        node a
        INNER JOIN field_data_field_meeting_type f ON a.nid = f.entity_id
        INNER JOIN taxonomy_term_data g ON f.field_meeting_type_tid = g.tid
        INNER JOIN field_data_field_document_meeting h ON h.field_document_meeting_target_id = a.nid
    WHERE
        a.type = 'meeting'
        AND lcase(g.name) IN ('cop', 'mop');

CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions` AS
    SELECT
        a.uuid AS id,
        CONCAT('http://eurobats.eaudeweb.ro/node/', a.nid) AS link,
        b1.name AS `type`,
        -- c1.name AS `status`,
        d.field_document_number_value AS number,
        lower(e1.title) AS treaty,
        f.field_document_publish_date_value AS published,
        -- date_format(from_unixtime(a.created),'%Y-%m-%d %H:%i:%s') AS updated,
        NOW() AS updated,
        g.id_meeting AS meetingId,
        NULL AS meetingTitle,
        NULL AS meetingUrl
    FROM node a
        INNER JOIN field_data_field_document_type b ON b.entity_id = a.nid
        INNER JOIN taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
        -- INNER JOIN field_data_field_document_status c ON c.entity_id = a.nid
        INNER JOIN taxonomy_term_data c1 ON c.field_document_status_tid = c1.tid
        INNER JOIN field_data_field_document_number d ON d.entity_id = a.nid
        INNER JOIN field_data_field_document_instrument e ON e.entity_id = a.nid
        INNER JOIN node e1 ON e.field_document_instrument_target_id = e1.nid
        -- INNER JOIN field_data_field_document_publish_date f ON f.entity_id = a.nid
        INNER JOIN informea_decisions_cop_documents g ON g.id_document = a.nid
    WHERE
        a.`type`='document'
        AND LOWER(b1.name) IN ('recommendation', 'resolution', 'decision')
        AND LOWER (e1.title) IN ('eurobats');

--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_content` AS
    SELECT
        NULL as id, NULL as decision_id, NULL as `language`, NULL as content
    LIMIT 0;

--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_documents` AS
    SELECT
        CONCAT(b.entity_id, '-', e.fid) as id,
        b.entity_id as decision_id,
        CONCAT('/var/local/eurobats/www/sites/default/files/', REPLACE(e.uri, 'public://', '')) as diskPath,
        CONCAT('http://eurobats.eaudeweb.ro/sites/default/files/', REPLACE(e.uri, 'public://', '')) as url,
        e.filemime as mimeType,
        d.`language` as language,
        e.filename as filename
    FROM field_data_field_decision_document b
    INNER JOIN field_data_field_document_files c ON c.entity_id = b.field_decision_document_target_id
    INNER JOIN field_data_field_document_file d ON d.entity_id = c.field_document_files_value
    INNER JOIN file_managed e ON e.fid = d.field_document_file_fid;

--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_keywords` AS
    SELECT
        NULL as id, NULL as decision_id, NULL as `namespace`, NULL as term
    LIMIT 0;
--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_longtitle` AS
    SELECT
        NULL as id, NULL as decision_id, NULL as `language`, NULL as long_title
    LIMIT 0;
--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_summary` AS
    SELECT
        CONCAT(a.uuid, '-en') as id,
        a.nid as decision_id,
        'en' as `language`,
        b.field_decision_summary_value as description
    FROM node a
    INNER JOIN field_data_field_decision_summary b ON a.nid = b.entity_id;
--
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_title` AS
SELECT
CONCAT(a.nid, '-', 'en') as id,
a.nid as decision_id,
'en' as `language`,
a.title as title
FROM node a WHERE a.`type` = 'decision';

