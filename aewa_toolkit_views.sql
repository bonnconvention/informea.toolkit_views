-- Helper view
CREATE OR REPLACE VIEW informea_treaty_machine_name AS
  SELECT
    nid,
    uuid,
    CASE
    WHEN nid = 1 THEN 'cms'
    WHEN nid = 2 THEN 'aewa'
    WHEN nid = 3 THEN 'eurobats'
    WHEN nid = 4 THEN 'ascobans'
    WHEN nid = 5 THEN 'accobams'
    WHEN nid = 6 THEN 'wadden-sea-seals'
    WHEN nid = 7 THEN 'acap'
    WHEN nid = 8 THEN 'gorilla'
    WHEN nid = 9 THEN 'siberian-crane'
    WHEN nid = 10 THEN 'slender-billed-curlew'
    WHEN nid = 11 THEN 'middle-european-great-bustard'
    WHEN nid = 12 THEN 'atlantic-turtles'
    WHEN nid = 13 THEN 'iosea-marine-turtles'
    WHEN nid = 14 THEN 'bukhara-deer'
    WHEN nid = 15 THEN 'aquatic-warbler'
    WHEN nid = 16 THEN 'west-african-elephants'
    WHEN nid = 17 THEN 'saiga-antelope'
    WHEN nid = 18 THEN 'pacific-inslands-cetaceans'
    WHEN nid = 19 THEN 'ruddy-headed-goose'
    WHEN nid = 20 THEN 'southern-south-american-grassland-birds'
    WHEN nid = 21 THEN 'monk-seal-atlantic'
    WHEN nid = 22 THEN 'dugong'
    WHEN nid = 23 THEN 'western-african-aquatic-mammals'
    WHEN nid = 24 THEN 'birds-of-prey'
    WHEN nid = 25 THEN 'high-andean-flamingos'
    WHEN nid = 26 THEN 'sharks'
    WHEN nid = 27 THEN 'south-andean-huemul'
    ELSE
      NULL
    END treaty,
    title
  FROM `prod_cms`.node
  WHERE `type` = 'legal_instrument' AND nid IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);


-- Meetings

-- informea_meetings
CREATE OR REPLACE VIEW `informea_meetings` AS
  SELECT
    a.uuid                                                     AS id,
    LOWER(instr_name.title)                                    AS treaty,
    CONCAT('https://www.unep-aewa.org/node/', a.nid)            AS url,
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
    j.field_meeting_latitude_value                             AS latitude,
    k.field_meeting_longitude_value                            AS longitude,
    date_format(from_unixtime(a.changed), '%Y-%m-%d %H:%i:%s') AS updated
  FROM
    `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_field_instrument instr ON a.nid = instr.entity_id
    LEFT JOIN `prod_aewa`.node instr_name ON instr.field_instrument_target_id = instr_name.nid
    INNER JOIN `prod_aewa`.field_data_event_calendar_date b ON a.nid = b.entity_id
    LEFT JOIN `prod_aewa`.field_data_field_meeting_kind d ON a.nid = d.entity_id
    LEFT JOIN `prod_aewa`.taxonomy_term_data d1 ON d.field_meeting_kind_tid = d1.tid
    INNER JOIN `prod_aewa`.field_data_field_meeting_type e ON a.nid = e.entity_id
    INNER JOIN `prod_aewa`.taxonomy_term_data e1 ON e.field_meeting_type_tid = e1.tid
    LEFT JOIN `prod_aewa`.field_data_field_meeting_status f ON a.nid = f.entity_id
    LEFT JOIN `prod_aewa`.taxonomy_term_data f1 ON f.field_meeting_status_tid = f1.tid
    LEFT JOIN `prod_aewa`.field_revision_field_meeting_location g ON a.nid = g.entity_id
    LEFT JOIN `prod_aewa`.field_data_field_meeting_city h ON a.nid = h.entity_id
    INNER JOIN `prod_aewa`.field_data_field_country i ON (i.entity_id = a.nid AND i.bundle = 'meeting')
    INNER JOIN `prod_aewa`.field_data_field_country_iso2 i1 ON i.field_country_target_id = i1.entity_id
    LEFT JOIN `prod_aewa`.field_data_field_meeting_latitude j ON a.nid = j.entity_id
    LEFT JOIN `prod_aewa`.field_data_field_meeting_longitude k ON a.nid = k.entity_id
  WHERE
    a.status = 1
    AND a.`type` = 'meeting'
    AND LOWER(instr_name.title) = 'aewa'
    AND (b.event_calendar_date_value IS NOT NULL OR b.event_calendar_date_value <> '')
  GROUP BY a.uuid;

-- informea_meetings_description
CREATE OR REPLACE VIEW `informea_meetings_description` AS
  SELECT
    CONCAT(a.uuid, '-en') AS id,
    a.uuid                AS meeting_id,
    'en'                  AS `language`,
    b.body_value          AS description
  FROM `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_body b ON a.nid = b.entity_id
  WHERE
    a.status = 1
    AND b.body_value IS NOT NULL
    AND TRIM(b.body_value) <> '';


-- informea_meetings_title
CREATE OR REPLACE VIEW `informea_meetings_title` AS
  SELECT
    CONCAT(a.uuid, '-en') AS id,
    a.uuid                AS meeting_id,
    'en'                  AS 'language',
    a.title
  FROM `prod_aewa`.node a
  WHERE
    a.status = 1
    AND a.`type` = 'meeting';


-- DECISIONS

-- informea_decisions_cop_documents - Support view with COP meetings and their documents IDs
CREATE OR REPLACE VIEW `informea_decisions_cop_documents` AS
  SELECT
    a.uuid      AS id_meeting,
    h.entity_id AS id_document
  FROM
    `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_field_meeting_type f ON a.nid = f.entity_id
    INNER JOIN `prod_aewa`.taxonomy_term_data g ON f.field_meeting_type_tid = g.tid
    INNER JOIN `prod_aewa`.field_data_field_document_meeting h ON h.field_document_meeting_target_id = a.nid
  WHERE
    a.status = 1
    AND a.`type` = 'meeting'
    AND LOWER(g.name) IN ('cop', 'mop');


-- informea_decisions
-- Resolution: 1332, Recommendation: 1334, Decision: 1335
CREATE OR REPLACE VIEW `informea_decisions` AS
  SELECT
    a.uuid                                                     AS id,
    CONCAT('https://www.unep-aewa.org/node/', a.nid)        AS link,
    CASE b.field_document_type_tid WHEN 1332 THEN 'resolution'
      WHEN 1334 THEN 'recommendation'
      ELSE 'decision'
    END                                                        AS `type`,
    'Adopted'                                                  AS `status`,
    d.field_document_number_value                              AS number,
    lower(e1.title)                                            AS treaty,
    f.field_document_publish_date_value                        AS published,
    date_format(from_unixtime(a.created), '%Y-%m-%d %H:%i:%s') AS updated,
    g.id_meeting                                               AS meetingId,
    NULL                                                       AS meetingTitle,
    NULL                                                       AS meetingUrl,
    dg.weight                                                  AS displayOrder,
    a.nid
  FROM `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_document_number d ON d.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_instrument e ON e.entity_id = a.nid
    INNER JOIN `prod_aewa`.node e1 ON e.field_instrument_target_id = e1.nid
    INNER JOIN `prod_aewa`.field_data_field_document_publish_date f ON f.entity_id = a.nid
    INNER JOIN informea_decisions_cop_documents g ON g.id_document = a.nid
    LEFT JOIN `prod_cms`.draggableviews_structure dg ON (dg.view_name = 'meeting_documents_list_reorder' AND dg.entity_id = a.nid)
  WHERE
    a.status = 1
    AND a.`type` = 'document'
    AND LOWER(b.field_document_type_tid) IN (1332, 1334, 1335)
    AND LOWER(e1.title) IN ('aewa')
  GROUP BY a.uuid;

-- informea_decisions_content
CREATE OR REPLACE VIEW `informea_decisions_content` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `language`,
    NULL AS content
  LIMIT 0;

-- informea_decisions_documents
CREATE OR REPLACE VIEW `informea_decisions_documents` AS
  SELECT
    CONCAT(a.uuid, '-', f2.fid)                                                               AS id,
    a.uuid                                                                                    AS decision_id,
    CONCAT('/var/local/aewa/www/sites/default/files/', REPLACE(f2.uri, 'public://', ''))      AS diskPath,
    CONCAT('https://www.unep-aewa.org/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS url,
    f2.filemime                                                                               AS mimeType,
    f1.`language`                                                                             AS `language`,
    f2.filename                                                                               AS filename
  FROM `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `prod_aewa`.taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
    INNER JOIN `prod_aewa`.field_data_field_document_number d ON d.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_instrument e ON e.entity_id = a.nid
    INNER JOIN `prod_aewa`.node e1 ON e.field_instrument_target_id = e1.nid
    INNER JOIN `prod_aewa`.field_data_field_document_files f ON f.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_document_file f1 ON f1.entity_id = f.field_document_files_value
    INNER JOIN `prod_aewa`.file_managed f2 ON f2.fid = f1.field_document_file_fid
  WHERE
    a.status = 1
    AND a.`type` = 'document'    AND LOWER(b1.name) IN ('resolution', 'resolutions', 'recommendation', 'decision')
    AND LOWER(e1.title) IN ('aewa')
    AND f2.filemime IN ('application/pdf', 'application/msword');

-- informea_decisions_keywords
CREATE OR REPLACE VIEW `informea_decisions_keywords` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `namespace`,
    NULL AS term
  LIMIT 0;

-- informea_decisions_longtitle
CREATE OR REPLACE VIEW `informea_decisions_longtitle` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `language`,
    NULL AS long_title
  LIMIT 0;

-- informea_decisions_summary
CREATE OR REPLACE VIEW `informea_decisions_summary` AS
  SELECT
    NULL AS id,
    NULL AS decision_id,
    NULL AS `language`,
    NULL AS summary
  LIMIT 0;

-- informea_decisions_title
CREATE OR REPLACE VIEW `informea_decisions_title` AS
  SELECT
    CONCAT(a.uuid, '-', 'en') AS id,
    a.uuid                    AS decision_id,
    'en'                      AS `language`,
    a.title                   AS title
  FROM `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `prod_aewa`.taxonomy_term_data b1 ON b.field_document_type_tid = b1.tid
    INNER JOIN `prod_aewa`.field_data_field_document_number d ON d.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_instrument e ON e.entity_id = a.nid
    INNER JOIN `prod_aewa`.node e1 ON e.field_instrument_target_id = e1.nid
  WHERE
    a.status = 1
    AND a.`type` = 'document';

-- COUNTRY REPORTS (National Reports)

-- informea_country_reports
-- National Report: 1336
CREATE OR REPLACE VIEW `informea_country_reports` AS
  SELECT
    a.uuid                                                     AS id,
    'aewa'                                                      AS treaty,
    UPPER(h.field_country_iso3_value)                          AS country,
    f.field_document_publish_date_value                        AS submission,
    CONCAT('https://www.unep-aewa.org/node/', a.nid)                  AS url,
    date_format(from_unixtime(a.created), '%Y-%m-%d %H:%i:%s') AS updated
  FROM `prod_aewa`.node a
    INNER JOIN `prod_aewa`.field_data_field_document_type b ON b.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_instrument e ON e.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_document_publish_date f ON f.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_country g ON (g.entity_id = a.nid AND g.bundle = 'document')
    INNER JOIN `prod_aewa`.field_data_field_country_iso3 h ON g.field_country_target_id = h.entity_id
  WHERE
    a.`type` = 'document'
    AND LOWER(b.field_document_type_tid) IN (1336)
  GROUP BY a.uuid;

-- informea_country_reports_documents
CREATE OR REPLACE VIEW `informea_country_reports_documents` AS
  SELECT
    CONCAT('en', '-', n.nid) AS id,
    n.uuid AS country_report_id,
    CONCAT('sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS diskPath,
    CONCAT('https://www.unep-aewa.org/sites/default/files/', REPLACE(f2.uri, 'public://', '')) AS url,
    f2.filemime AS mimeType,
    CASE f1.`language` WHEN 'und' THEN 'en'
      ELSE f1.`language`
    END                                                        AS `language`,
    f2.filename AS filename
  FROM `prod_aewa`.node n
    INNER JOIN `prod_aewa`.field_data_field_document_type dt ON n.nid = dt.entity_id
    INNER JOIN `prod_aewa`.field_data_field_document_files f ON f.entity_id = n.nid
    INNER JOIN `prod_aewa`.field_data_field_document_file f1 ON f1.entity_id = f.field_document_files_value
    INNER JOIN `prod_aewa`.file_managed f2 ON f2.fid = f1.field_document_file_fid
    INNER JOIN `prod_aewa`.field_data_field_country g ON (g.entity_id = n.nid AND g.bundle = 'document')
    INNER JOIN `prod_aewa`.field_data_field_country_iso3 h ON g.field_country_target_id = h.entity_id
  WHERE
    n.type ='document'
    AND n.status = 1
    AND dt.field_document_type_tid = 1336
    GROUP BY f2.fid;

-- informea_country_reports_title
CREATE OR REPLACE VIEW `informea_country_reports_title` AS
  SELECT
    CONCAT(id, '-en') AS id,
    id                AS country_report_id,
    'en'              AS 'language',
    b.title
  FROM informea_country_reports a INNER JOIN `prod_aewa`.node b ON a.id = b.uuid;


--
-- Document entity view
--
CREATE OR REPLACE VIEW informea_documents AS
  SELECT
    1 schemaVersion,
    node.uuid id,
    CONVERT(field_publication_published_date_timestamp, DATE) AS published,
    FROM_UNIXTIME(node.changed) updated,
    NULL AS treaty,
    REPLACE(thumbnails.uri, 'public://', 'https://www.unep-aewa.org/sites/default/files/') thumbnailUrl,
    0 displayOrder,
    UPPER(ciso.field_country_iso3_value) country,
    node.nid
  FROM `prod_aewa`.node node
    LEFT JOIN `prod_aewa`.field_data_field_publication_published_date pdate ON node.nid = pdate.entity_id
    LEFT JOIN `prod_aewa`.field_data_field_publication_image img ON node.nid = img.entity_id
    LEFT JOIN `prod_aewa`.file_managed thumbnails ON field_publication_image_fid = thumbnails.fid
    LEFT JOIN `prod_aewa`.field_data_field_country country ON country.entity_id = node.nid
    LEFT JOIN `prod_aewa`.field_data_field_country_iso3 ciso ON country.field_country_target_id = ciso.entity_id
  WHERE
    node.type = 'publication'
    AND node.status = 1
  GROUP BY node.nid;


--
-- Documents `treaties` navigation property
--
CREATE OR REPLACE VIEW `informea_documents_treaties` AS
  SELECT
    CAST(concat(a.ID, '-', treaty.treaty) AS CHAR) AS `id`,
    CAST(a.ID AS CHAR) AS document_id,
    treaty.treaty AS treaty,
    a.nid
  FROM `informea_documents` a
  INNER JOIN `prod_aewa`.field_data_field_instrument instr ON a.nid = instr.entity_id
  INNER JOIN informea_treaty_machine_name treaty ON (treaty.nid = instr.field_instrument_target_id AND instr.entity_type = 'node');


--
-- Documents `type` navigation property
--
CREATE OR REPLACE VIEW informea_documents_types AS
  SELECT
    CONCAT(a.id, '-', 'publication') AS id,
    a.id document_id,
    'Publication' `value`
  FROM informea_documents a
  UNION
  SELECT
    CONCAT(a.id, '-', tb.tid) AS id,
    a.id document_id,
    CASE
    WHEN tb.tid = 1942 THEN 'Factsheet'
    WHEN tb.tid = 229 THEN 'Guidance'
    ELSE
      tb.name
    END `value`
  FROM informea_documents a
    INNER JOIN `prod_aewa`.field_data_field_publication_type b ON a.nid = b.entity_id
    INNER JOIN `prod_aewa`.taxonomy_term_data tb ON b.field_publication_type_tid = tb.tid
  WHERE tb.tid IN (223, 224, 226, 369) ORDER BY document_id;

--
-- Documents `authors` navigation property
--
CREATE OR REPLACE VIEW informea_documents_authors AS
  SELECT
    CONCAT(a.nid, '-', tb.tid) id,
    a.id document_id,
    NULL `type`,
    tb.name
  FROM informea_documents a
    INNER JOIN `prod_aewa`.field_data_field_publication_author b ON a.nid = b.entity_id
    INNER JOIN `prod_aewa`.taxonomy_term_data tb ON tb.tid = b.field_publication_author_tid;

--
-- Documents `keywords` navigation property
--
CREATE OR REPLACE VIEW informea_documents_keywords AS
  SELECT
    CONCAT(a.id, '-', td.tid) AS id,
    a.id document_id,
    'https://www.informea.org/terms' AS `termURI`,
    'leo' AS scope,
    td.name AS literalForm,
    'https://www.informea.org/terms' AS sourceURL
  FROM informea_documents a
    INNER JOIN `prod_aewa`.field_data_field_cms_tags tags ON tags.entity_id = a.nid
    INNER JOIN `prod_aewa`.field_data_field_related_informea_terms itags ON tags.field_cms_tags_tid = itags.entity_id
    INNER JOIN `prod_aewa`.taxonomy_term_data td ON itags.field_related_informea_terms_target_id = td.tid;

--
-- Documents `titles` navigation property
--
CREATE OR REPLACE VIEW informea_documents_title AS
  SELECT
    CONCAT(a.nid, '-', CASE WHEN b.language = 'und' THEN 'en' ELSE b.language END) id,
    a.id document_id,
    CASE WHEN b.language = 'und' THEN 'en' ELSE b.language END `language`,
    b.title_field_value `value`
  FROM informea_documents a
    INNER JOIN `prod_aewa`.field_data_title_field b ON a.nid = b.entity_id
  GROUP BY CONCAT(a.nid, '-', CASE WHEN b.language = 'und' THEN 'en' ELSE b.language END);

--
-- Documents `descriptions` navigation property
--
CREATE OR REPLACE VIEW informea_documents_description AS
  SELECT
    CONCAT(a.id, '-', CASE WHEN b.language = 'und' THEN 'en' ELSE b.language END) AS id,
    a.id document_id,
    CASE WHEN b.language = 'und' THEN 'en' ELSE b.language END `language`,
    b.body_value `value`
  FROM informea_documents a
    INNER JOIN `prod_aewa`.field_data_body b ON a.nid = b.entity_id
  GROUP BY CONCAT(a.id, '-', CASE WHEN b.language = 'und' THEN 'en' ELSE b.language END);

--
-- Documents `identifiers` navigation property
-- @todo
--
CREATE OR REPLACE VIEW informea_documents_identifiers AS
  SELECT
    NULL id,
    NULL document_id,
    NULL name,
    NULL value
  FROM DUAL;

--
-- Documents `files` navigation property
--
CREATE OR REPLACE VIEW informea_documents_files AS
  SELECT
    files.fid id,
    a.id document_id,
    REPLACE(files.uri, 'public://', 'https://www.unep-aewa.org/sites/default/files/') url,
    NULL content,
    files.filemime AS mimeType,
    CASE WHEN f.language = 'und' THEN 'en' ELSE f.language END `language`,
    files.filename
  FROM informea_documents a
    INNER JOIN `prod_aewa`.field_data_field_publication_attachment f ON a.nid = f.entity_id
    INNER JOIN `prod_aewa`.file_managed files ON f.field_publication_attachment_fid = files.fid
  GROUP BY files.fid;

--
-- Documents `tags` navigation property
-- @todo:
--
CREATE OR REPLACE VIEW informea_documents_tags AS
  SELECT
    NULL id,
    NULL document_id,
    NULL language,
    NULL scope,
    NULL value,
    NULL comment
  FROM DUAL;

--
-- Documents `referenceToEntities` navigation property
-- @todo:
--
CREATE OR REPLACE VIEW `informea_documents_references` AS
  SELECT
      CONCAT('meeting-', a.nid, '-', bn.nid) AS id,
      'meeting' AS type, a.id AS document_id,
      NULL AS refId
    FROM
      informea_documents a
      JOIN `prod_aewa`.field_data_field_publication_meeting b ON a.nid = b.entity_id
      JOIN `prod_aewa`.node bn ON (b.field_publication_meeting_target_id = bn.nid AND bn.type = 'meeting')
    GROUP BY bn.nid
  UNION
    SELECT
        CONCAT('NationalPlans-', a.nid, '-', bn.nid) AS id,
      'NationalPlans' AS type,
      a.id AS document_id,
      NULL AS refId
    FROM
      informea_documents a
      JOIN `prod_aewa`.field_data_field_publication_plans b ON a.nid = b.entity_id
      JOIN `prod_aewa`.node bn ON (b.field_publication_plans_target_id = bn.nid and (bn.type = 'document'))
    GROUP BY bn.nid
  UNION
    SELECT
      concat('CountryReports-', a.nid, '-', bn.nid) AS id,
      'CountryReports' AS type,
      a.id AS document_id,
      NULL AS refId
    FROM
      informea_documents a
      JOIN `prod_aewa`.field_data_field_publication_nat_report b ON a.nid = b.entity_id
      JOIN `prod_aewa`.node bn ON (b.field_publication_nat_report_target_id = bn.nid AND bn.type = 'document')
    GROUP BY bn.nid;


-- CONTACTS (Focal Points)
CREATE OR REPLACE VIEW `informea_contacts` AS
  SELECT
    MD5(dn) AS id,
    country_iso2 AS country,
    '' AS prefix,
    first_name AS firstName,
    last_name AS lastName,
    position AS `position`,
    organization AS institution,
    '' AS department,
    '' AS `type`,
    address AS address,
    work_email AS email,
    telephone AS phoneNumber,
    fax AS fax,
    1 AS `primary`,
    FROM_UNIXTIME(NOW()) AS updated
  FROM `prod_aewa`.odata_focal_point a;


-- informea_contacts_treaties
CREATE OR REPLACE VIEW `informea_contacts_treaties` AS
  SELECT
    CONCAT(id, '-aewa') as id,
    id AS contact_id,
    'aewa' AS treaty
  FROM `informea_contacts`;
