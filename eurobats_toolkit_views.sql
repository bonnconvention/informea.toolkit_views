-- Meetings

-- informea_meetings
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings` AS
    SELECT
        a.uuid AS id,
        LOWER(instr_name.title) AS treaty,
        CONCAT('http://www.eurobats.org/node/', a.nid) AS url,
        b.field_meeting_start_value AS `start`,
        c.field_meeting_end_value AS `end`,
        NULL AS repetition,
        LOWER(d1.name) AS kind,
        LOWER(e1.name) AS `type`,
        NULL AS access,
        LOWER(f1.name) AS `status`,
        NULL AS imageUrl,
        NULL AS imageCopyright,
        g.field_meeting_location_value AS location,
        h.field_meeting_city_value AS city,
        i1.field_country_iso2_value AS country,
        j.field_meeting_latitude_value AS `latitude`,
        k.field_meeting_longitude_value AS `longitude`,
        date_format(from_unixtime(a.changed),'%Y-%m-%d %H:%i:%s') AS updated
    FROM
        node a
        INNER JOIN field_data_field_instrument instr ON a.nid = instr.entity_id
        LEFT JOIN node instr_name ON instr.field_instrument_target_id = instr_name.nid
        INNER JOIN field_data_field_meeting_start b ON a.nid = b.entity_id
        LEFT JOIN field_data_field_meeting_end c ON a.nid = c.entity_id
        LEFT JOIN field_data_field_meeting_kind d ON a.nid = d.entity_id
        LEFT JOIN taxonomy_term_data d1 ON d.field_meeting_kind_tid = d1.tid
        INNER JOIN field_data_field_meeting_type e ON a.nid = e.entity_id
        INNER JOIN taxonomy_term_data e1 ON e.field_meeting_type_tid = e1.tid
        LEFT JOIN field_data_field_meeting_status f ON a.nid = f.entity_id
        LEFT JOIN taxonomy_term_data f1 ON f.field_meeting_status_tid = f1.tid
        LEFT JOIN field_revision_field_meeting_location g ON a.nid = g.entity_id
        LEFT JOIN field_data_field_meeting_city h ON a.nid = h.entity_id
        INNER JOIN field_data_field_country i ON a.nid = i.entity_id
        INNER JOIN field_data_field_country_iso2 i1 ON i.field_country_target_id = i1.entity_id
        LEFT JOIN field_data_field_meeting_latitude j ON a.nid = j.entity_id
        LEFT JOIN field_data_field_meeting_longitude k ON a.nid = k.entity_id
    WHERE
        a.`type` = 'meeting'
        AND LOWER(e1.name) IN ('cop', 'mop')
        AND LOWER(instr_name.title) = 'eurobats'
    GROUP BY a.uuid;


-- informea_meetings_description
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings_description` AS
    SELECT
        CONCAT(a.uuid, '-en') AS id,
        a.uuid AS meeting_id,
        'en' AS `language`,
        b.body_value AS description
    FROM node a
        INNER JOIN field_data_body b ON a.nid = b.entity_id
        WHERE
            b.body_value IS NOT NULL
            AND TRIM(b.body_value) <> '';


-- informea_meetings_title
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings_title` AS
    SELECT
        CONCAT(a.uuid, '-en') AS id,
        a.uuid AS meeting_id,
        'en' AS 'language',
        a.title
    FROM node a WHERE a.`type` = 'meeting';


-- DECISIONS

-- informea_decisions_cop_documents - Support view with COP meetings and their documents IDs
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_cop_documents` AS
    SELECT
        a.uuid AS id_meeting,
        h.entity_id AS id_document
    FROM
        node a
        INNER JOIN field_data_field_meeting_type f ON a.nid = f.entity_id
        INNER JOIN taxonomy_term_data g ON f.field_meeting_type_tid = g.tid
        INNER JOIN field_data_field_document_meeting h ON h.field_document_meeting_target_id = a.nid
    WHERE
        a.type = 'meeting'
        AND LOWER(g.name) IN ('cop', 'mop');


-- informea_decisions
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions` AS
    SELECT
        a.uuid AS id,
        CONCAT('http://www.eurobats.org/node/', a.nid) AS link,
        b1.name AS `type`,
        c1.name AS `status`,
        d.field_document_number_value AS number,
        lower(e1.title) AS treaty,
        f.field_document_publish_date_value AS published,
        date_format(from_unixtime(a.created),'%Y-%m-%d %H:%i:%s') AS updated,
        g.id_meeting AS meetingId,
        NULL AS meetingTitle,
        NULL AS meetingUrl
    FROM node a
        INNER JOIN field_data_field_document_type b ON b.entity_id = a.nid
        INNER JOIN taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
        INNER JOIN field_data_field_document_status c ON c.entity_id = a.nid
        INNER JOIN taxonomy_term_data c1 ON c.field_document_status_tid = c1.tid
        INNER JOIN field_data_field_document_number d ON d.entity_id = a.nid
        INNER JOIN field_data_field_instrument e ON e.entity_id = a.nid
        INNER JOIN node e1 ON e.field_instrument_target_id = e1.nid
        INNER JOIN field_data_field_document_publish_date f ON f.entity_id = a.nid
        INNER JOIN informea_decisions_cop_documents g ON g.id_document = a.nid
    WHERE
        a.`type`='document'
        AND LOWER(b1.name) IN ('resolution', 'recommendation', 'decision')
        AND LOWER (e1.title) IN ('eurobats');


-- informea_decisions_content
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_content` AS
    SELECT
        NULL AS id, NULL AS decision_id, NULL AS `language`, NULL AS content
    LIMIT 0;


-- informea_decisions_documents
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_documents` AS
    SELECT
        CONCAT(a.uuid, '-', f2.fid) AS id,
        a.uuid AS decision_id,
        CONCAT('/var/local/eurobats/www/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS diskPath,
        CONCAT('http://www.eurobats.org/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS url,
        f2.filemime AS mimeType,
        f1.`language` AS language,
        f2.filename AS filename
    FROM node a
        INNER JOIN field_data_field_document_type b ON b.entity_id = a.nid
        INNER JOIN taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
        INNER JOIN field_data_field_document_status c ON c.entity_id = a.nid
        INNER JOIN taxonomy_term_data c1 ON c.field_document_status_tid = c1.tid
        INNER JOIN field_data_field_document_number d ON d.entity_id = a.nid
        INNER JOIN field_data_field_instrument e ON e.entity_id = a.nid
        INNER JOIN node e1 ON e.field_instrument_target_id = e1.nid
        INNER JOIN field_data_field_document_files f ON f.entity_id = a.nid
        INNER JOIN field_data_field_document_file f1 ON f1.entity_id = f.field_document_files_value
        INNER JOIN file_managed f2 ON f2.fid = f1.field_document_file_fid
    WHERE
        a.`type`='document'
        AND LOWER(b1.name) IN ('resolution', 'recommendation', 'decision')
        AND LOWER (e1.title) IN ('eurobats')
        AND f2.filemime IN ('application/pdf', 'application/msword');


-- informea_decisions_keywords
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_keywords` AS
    SELECT
        NULL AS id, NULL AS decision_id, NULL AS `namespace`, NULL AS term
    LIMIT 0;


-- informea_decisions_longtitle
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_longtitle` AS
    SELECT
        NULL AS id, NULL AS decision_id, NULL AS `language`, NULL AS long_title
    LIMIT 0;


-- informea_decisions_summary
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_summary` AS
    SELECT
        NULL AS id, NULL AS decision_id, NULL AS language, NULL AS summary
    LIMIT 0;


-- informea_decisions_title
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_decisions_title` AS
    SELECT
        CONCAT(a.uuid, '-', 'en') AS id,
        a.uuid AS decision_id,
        'en' AS `language`,
        a.title AS title
    FROM node a
        INNER JOIN field_data_field_document_type b ON b.entity_id = a.nid
        INNER JOIN taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
        INNER JOIN field_data_field_document_status c ON c.entity_id = a.nid
        INNER JOIN taxonomy_term_data c1 ON c.field_document_status_tid = c1.tid
        INNER JOIN field_data_field_document_number d ON d.entity_id = a.nid
        INNER JOIN field_data_field_instrument e ON e.entity_id = a.nid
        INNER JOIN node e1 ON e.field_document_instrument_target_id = e1.nid
    WHERE
        a.`type`='document'
        AND LOWER(b1.name) IN ('resolution', 'recommendation', 'decision')
        AND LOWER (e1.title) IN ('eurobats');


-- COUNTRY REPORTS (National Reports)

-- informea_country_reports
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_country_reports` AS
    SELECT
        a.uuid AS id,
        'eurobats' AS treaty,
        UPPER(h.field_country_iso3_value) AS country,
        f.field_document_publish_date_value AS submission,
        CONCAT('http://www.eurobats.org/node/', a.nid) AS url,
        date_format(from_unixtime(a.created),'%Y-%m-%d %H:%i:%s') AS updated
    FROM node a
        INNER JOIN field_data_field_document_type b ON b.entity_id = a.nid
        INNER JOIN taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
        INNER JOIN field_data_field_instrument e ON e.entity_id = a.nid
        INNER JOIN node e1 ON e.field_instrument_target_id = e1.nid
        INNER JOIN field_data_field_document_publish_date f ON f.entity_id = a.nid
        INNER JOIN field_data_field_country g ON g.entity_id = a.nid
        INNER JOIN field_data_field_country_iso3 h ON g.field_country_target_id = h.entity_id
    WHERE
        a.`type`='document'
        AND LOWER(b1.name) = 'national report'
        AND LOWER (e1.title) IN ('eurobats');


-- informea_country_reports_title
CREATE OR REPLACE DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_country_reports_title` AS
    SELECT
        CONCAT(a.uuid, '-en') AS id,
        a.uuid AS country_report_id,
        'en' AS 'language',
        a.title
    FROM node a WHERE a.`type` = 'document';
