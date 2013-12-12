-- Meetings
CREATE ALGORITHM=UNDEFINED DEFINER=`edw_www`@`localhost` SQL SECURITY DEFINER VIEW `informea_meetings`
CREATE OR REPLACE VIEW informea_meetings AS
    SELECT
        a.uuid as id,
        LOWER(instr_name.title) AS treaty,
        CONCAT('http://ascobans.eaudeweb.ro/node/', a.nid) as url,
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
        AND LOWER(instr_name.title) IN ('ascobans');

--
CREATE OR REPLACE VIEW informea_meetings_description AS
    SELECT
        CONCAT(a.uuid, '-en') as id,
        a.uuid as meeting_id,
        'en' as `language`,
        b.field_meeting_description_value as description
    FROM node a
    INNER JOIN field_data_field_meeting_description b ON a.nid = b.entity_id;


CREATE OR REPLACE VIEW informea_meetings_title AS
    SELECT
        CONCAT(a.uuid, '-en') as id,
        a.uuid as meeting_id,
        'en' as 'language',
        a.title
    FROM node a WHERE a.`type` = 'meeting';

-- decisions
CREATE OR REPLACE VIEW informea_decisions AS
    SELECT
        a.uuid as id,
        CONCAT('http://ascobans.eaudeweb.ro/node/', a.nid) as link,
        e.name as `type`,
        c.name as `status`,
        f.field_decision_number_value as `number`,
        'ascobans' as treaty,
        g.field_decision_publish_date_value as `published`,
        FROM_UNIXTIME(a.changed, '%Y-%m-%d %H:%i:%s') as updated,
        h.field_decision_meeting_target_id as meetingId,
    NULL as meetingTitle,
    NULL as meetingUrl
    FROM node a
    INNER JOIN field_data_field_decision_status b ON a.nid = b.entity_id
    INNER JOIN taxonomy_term_data c ON b.field_decision_status_tid = c.tid
    INNER JOIN field_data_field_decision_type d ON a.nid = d.entity_id
    INNER JOIN taxonomy_term_data e ON d.field_decision_type_tid = e.tid
    INNER JOIN field_data_field_decision_number f ON a.nid = f.entity_id
    INNER JOIN field_data_field_decision_publish_date g ON a.nid = g.entity_id
    INNER JOIN field_data_field_decision_meeting h ON a.nid = h.entity_id;

--
CREATE OR REPLACE VIEW informea_decisions_content AS SELECT NULL as id, NULL as decision_id, NULL as `language`, NULL as content LIMIT 0;

--
CREATE OR REPLACE VIEW informea_decisions_documents AS
    SELECT
        CONCAT(b.entity_id, '-', e.fid) as id,
        b.entity_id as decision_id,
        CONCAT('/var/local/ascobans/www/sites/default/files/', REPLACE(e.uri, 'public://', '')) as diskPath,
        CONCAT('http://ascobans.eaudeweb.ro/sites/default/files/', REPLACE(e.uri, 'public://', '')) as url,
        e.filemime as mimeType,
        d.`language` as language,
        e.filename as filename
    FROM field_data_field_decision_document b
    INNER JOIN field_data_field_document_files c ON c.entity_id = b.field_decision_document_target_id
    INNER JOIN field_data_field_document_file d ON d.entity_id = c.field_document_files_value
    INNER JOIN file_managed e ON e.fid = d.field_document_file_fid;

--
CREATE OR REPLACE VIEW informea_decisions_keywords AS SELECT NULL as id, NULL as decision_id, NULL as `namespace`, NULL as term LIMIT 0;
--
CREATE OR REPLACE VIEW informea_decisions_longtitle AS SELECT NULL as id, NULL as decision_id, NULL as `language`, NULL as long_title LIMIT 0;
--
CREATE OR REPLACE VIEW informea_decisions_summary AS
    SELECT
        CONCAT(a.uuid, '-en') as id,
        a.nid as decision_id,
        'en' as `language`,
        b.field_decision_summary_value as description
    FROM node a
    INNER JOIN field_data_field_decision_summary b ON a.nid = b.entity_id;
--
CREATE OR REPLACE VIEW informea_decisions_title AS
SELECT
CONCAT(a.nid, '-', 'en') as id,
a.nid as decision_id,
'en' as `language`,
a.title as title
FROM node a WHERE a.`type` = 'decision';

