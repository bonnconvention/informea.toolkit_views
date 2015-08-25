-- Meetings

-- informea_meetings
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_meetings` AS
  SELECT
    a.uuid                                                     AS id,
    LOWER(instr_name.title)                                    AS treaty,
    CONCAT('http://www.ascobans.org/node/', a.nid)             AS url,
    b.event_calendar_date_value                                AS `start`,
    b.event_calendar_date_value2                               AS `end`,
    NULL                                                       AS repetition,
    LOWER(d1.name)                                             AS kind,
    LOWER(e1.name)                                             AS `type`,
    NULL                                                       AS access,
    LOWER(f1.name)                                             AS `status`,
    NULL                                                       AS imageUrl,
    NULL                                                       AS imageCopyright,
    g.field_meeting_location_value                             AS location,
    h.field_meeting_city_value                                 AS city,
    i1.field_country_iso2_value                                AS country,
    j.field_meeting_latitude_value                             AS `latitude`,
    k.field_meeting_longitude_value                            AS `longitude`,
    date_format(from_unixtime(a.changed), '%Y-%m-%d %H:%i:%s') AS updated
  FROM
    `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_instrument instr ON a.nid = instr.entity_id
    LEFT JOIN `edw_ascobans_drupal`.node instr_name ON instr.field_instrument_target_id = instr_name.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_event_calendar_date b ON a.nid = b.entity_id
    LEFT JOIN `edw_ascobans_drupal`.field_data_field_meeting_kind d ON a.nid = d.entity_id
    LEFT JOIN `edw_ascobans_drupal`.taxonomy_term_data d1 ON d.field_meeting_kind_tid = d1.tid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_meeting_type e ON a.nid = e.entity_id
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data e1 ON e.field_meeting_type_tid = e1.tid
    LEFT JOIN `edw_ascobans_drupal`.field_data_field_meeting_status f ON a.nid = f.entity_id
    LEFT JOIN `edw_ascobans_drupal`.taxonomy_term_data f1 ON f.field_meeting_status_tid = f1.tid
    LEFT JOIN `edw_ascobans_drupal`.field_revision_field_meeting_location g ON a.nid = g.entity_id
    LEFT JOIN `edw_ascobans_drupal`.field_data_field_meeting_city h ON a.nid = h.entity_id
    INNER JOIN `edw_ascobans_drupal`.field_data_field_country i ON i.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_country_iso2 i1 ON i.field_country_target_id = i1.entity_id
    LEFT JOIN `edw_ascobans_drupal`.field_data_field_meeting_latitude j ON a.nid = j.entity_id
    LEFT JOIN `edw_ascobans_drupal`.field_data_field_meeting_longitude k ON a.nid = k.entity_id
  WHERE
    a.status = 1
    AND a.`type` = 'meeting'
    AND (b.event_calendar_date_value IS NOT NULL OR b.event_calendar_date_value <> '')
  GROUP BY a.uuid;


-- informea_meetings_description
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_meetings_description` AS
  SELECT
    CONCAT(a.uuid, '-en') AS id,
    a.uuid                AS meeting_id,
    'en'                  AS `language`,
    b.body_value          AS description
  FROM `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_body b ON a.nid = b.entity_id
  WHERE
    a.status = 1
    AND b.body_value IS NOT NULL
    AND TRIM(b.body_value) <> '';


-- informea_meetings_title
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_meetings_title` AS
  SELECT
    CONCAT(a.uuid, '-en') AS id,
    a.uuid                AS meeting_id,
    'en'                  AS 'language',
    a.title
  FROM `edw_ascobans_drupal`.node a
  WHERE
    a.status = 1
    AND a.`type` = 'meeting';


-- DECISIONS

-- informea_decisions_cop_documents - Support view with COP meetings and their documents IDs
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_cop_documents` AS
  SELECT
    a.uuid      AS id_meeting,
    h.entity_id AS id_document
  FROM
    `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_meeting_type f ON a.nid = f.entity_id
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data g ON f.field_meeting_type_tid = g.tid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_meeting h ON h.field_document_meeting_target_id = a.nid
  WHERE
    a.status = 1
    AND a.type = 'meeting'
    AND LOWER(g.name) IN ('cop', 'mop');


-- informea_decisions
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions` AS
  SELECT
    a.uuid                                                     AS id,
    CONCAT('http://www.ascobans.org/node/', a.nid)             AS link,
    CASE b1.name WHEN 'resolutions' THEN 'resolution'
      WHEN 'recommendations' THEN 'recommendation'
      ELSE 'decision'
    END                                                        AS `type`,
    'active'                                                   AS `status`,
    d.field_document_number_value                              AS number,
    lower(e1.title)                                            AS treaty,
    f.field_document_publish_date_value                        AS published,
    date_format(from_unixtime(a.created), '%Y-%m-%d %H:%i:%s') AS updated,
    g.id_meeting                                               AS meetingId,
    NULL                                                       AS meetingTitle,
    NULL                                                       AS meetingUrl
  FROM `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_status c ON c.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data c1 ON c.field_document_status_tid = c1.tid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_number d ON d.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_instrument e ON e.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.node e1 ON e.field_instrument_target_id = e1.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_publish_date f ON f.entity_id = a.nid
    INNER JOIN informea_decisions_cop_documents g ON g.id_document = a.nid
  WHERE
    a.status = 1
    AND a.`type` = 'document'
    AND LOWER(b1.name) IN ('resolutions', 'recommendations', 'decisions')
    AND LOWER(c1.name) = 'extant'
  GROUP BY a.uuid;

-- informea_decisions_content
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_content` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `language`,
    NULL AS content
  LIMIT 0;

-- informea_decisions_documents
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_documents` AS
  SELECT
    CONCAT(a.uuid, '-', f2.fid)                                                              AS id,
    a.uuid                                                                                   AS decision_id,
    CONCAT('/var/local/ascobans/www/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS diskPath,
    CONCAT('http://www.ascobans.org/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS url,
    f2.filemime                                                                              AS mimeType,
    f1.`language`                                                                            AS language,
    f2.filename                                                                              AS filename
  FROM `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_status c ON c.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data c1 ON c.field_document_status_tid = c1.tid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_number d ON d.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_instrument e ON e.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.node e1 ON e.field_instrument_target_id = e1.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_files f ON f.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_file f1 ON f1.entity_id = f.field_document_files_value
    INNER JOIN `edw_ascobans_drupal`.file_managed f2 ON f2.fid = f1.field_document_file_fid
  WHERE
    a.status = 1
    AND a.`type` = 'document'
    AND LOWER(b1.name) IN ('resolution', 'recommendation', 'decision')
    AND LOWER(e1.title) IN ('ascobans')
    AND f2.filemime IN ('application/pdf', 'application/msword');


-- informea_decisions_keywords
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_keywords` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `namespace`,
    NULL AS term
  LIMIT 0;


-- informea_decisions_longtitle
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_longtitle` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `language`,
    NULL AS long_title
  LIMIT 0;


-- informea_decisions_summary
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_summary` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS language,
    NULL AS summary
  LIMIT 0;


-- informea_decisions_title
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_decisions_title` AS
  SELECT
    CONCAT(a.uuid, '-', 'en') AS id,
    a.uuid                    AS decision_id,
    'en'                      AS `language`,
    a.title                   AS title
  FROM `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
  WHERE
    a.status = 1
    AND a.`type` = 'document'
    AND LOWER(b1.name) IN ('resolution', 'recommendation', 'decision');


-- COUNTRY REPORTS (National Reports)

-- informea_country_reports
--    449 = National report
--    4   = ASCOBANS
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_country_reports` AS
  SELECT
    a.uuid                                                     AS id,
    'ascobans'                                                 AS treaty,
    UPPER(h.field_country_iso3_value)                          AS country,
    f.field_document_publish_date_value                        AS submission,
    CONCAT('http://www.ascobans.org/node/', a.nid)             AS url,
    date_format(from_unixtime(a.created), '%Y-%m-%d %H:%i:%s') AS updated
  FROM `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_type b
      ON (b.entity_id = a.nid AND b.field_document_type_tid = 449)
    INNER JOIN `edw_ascobans_drupal`.field_data_field_instrument e
      ON (e.entity_id = a.nid AND e.field_instrument_target_id = 4)
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_publish_date f ON f.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_country g ON (g.entity_id = a.nid AND g.bundle = 'document')
    INNER JOIN `edw_ascobans_drupal`.field_data_field_country_iso3 h ON g.field_country_target_id = h.entity_id
  WHERE
    a.`type` = 'document'
  GROUP BY a.uuid;

-- informea_country_reports_documents
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_country_reports_documents` AS
  SELECT
    CONCAT('en', '-', a.nid) AS id,
    a.uuid AS country_report_id,
    CONCAT('sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS diskPath,
    CONCAT('http://www.ascobans.org/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS url,
    f2.filemime AS mimeType,
    CASE f1.`language` WHEN 'und' THEN 'en'
      ELSE f1.`language`
    END                                                        AS `language`,
    f2.filename AS filename
  FROM `edw_ascobans_drupal`.node a
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_type dt ON a.nid = dt.entity_id
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_files f ON f.entity_id = a.nid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_document_file f1 ON f1.entity_id = f.field_document_files_value
    INNER JOIN `edw_ascobans_drupal`.file_managed f2 ON f2.fid = f1.field_document_file_fid
    INNER JOIN `edw_ascobans_drupal`.field_data_field_instrument e ON (e.entity_id = a.nid AND e.field_instrument_target_id = 4)
    INNER JOIN `edw_ascobans_drupal`.field_data_field_country g ON (g.entity_id = a.nid AND g.bundle = 'document')
    INNER JOIN `edw_ascobans_drupal`.field_data_field_country_iso3 h ON g.field_country_target_id = h.entity_id
  WHERE
    a.status = 1
    AND a.type ='document'
    AND dt.field_document_type_tid = 449
    GROUP BY f2.fid;

-- informea_country_reports_title
CREATE OR REPLACE DEFINER =`edw_ascob_drupal`@`localhost`
  SQL SECURITY DEFINER VIEW `informea_country_reports_title` AS
  SELECT
    CONCAT(id, '-en') AS id,
    id                AS country_report_id,
    'en'              AS 'language',
    b.title
  FROM informea_country_reports a INNER JOIN `edw_ascobans_drupal`.node b ON a.id = b.uuid;
