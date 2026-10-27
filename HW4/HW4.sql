CREATE DATABASE IF NOT EXISTS space_missions;
USE space_missions;

CREATE TABLE countries (
    countrycode CHAR(3) PRIMARY KEY,
    countryname VARCHAR(50),
    continent VARCHAR(50)
);

CREATE TABLE organizations (
	orgid INT PRIMARY KEY,
    orgname VARCHAR(100),
    headquarterscountry CHAR(3),
    orgtype VARCHAR(50),
    FOREIGN KEY (headquarterscountry) REFERENCES countries (countrycode)
);

CREATE TABLE launch_sites (
	siteid INT PRIMARY KEY,
    sitename VARCHAR(100),
    countrycode CHAR(3),
    status VARCHAR(50),
    FOREIGN KEY (countrycode) REFERENCES countries (countrycode)
);

CREATE TABLE rockets (
	rocketid INT PRIMARY KEY,
    rocketname VARCHAR(100),
    orgid INT,
    payloadcapacitykg INT,
    operationalstatus VARCHAR(50),
    FOREIGN KEY (orgid) REFERENCES organizations (orgid)
);

CREATE TABLE missions (
	missionid INT PRIMARY KEY,
    missionname VARCHAR(100),
    rocketid INT,
    siteid INT,
    destination VARCHAR(50),
    launchyear INT,
    outcome VARCHAR(50),
    FOREIGN KEY (rocketid) REFERENCES rockets (rocketid),
    FOREIGN KEY (siteid) REFERENCES launch_sites (siteid)
);

CREATE TABLE payloads (
	payloadid INT PRIMARY KEY,
    missionid INT,
    payloadname VARCHAR(100),
    payloadtype VARCHAR(50),
    masskg DECIMAL(10,2),
    FOREIGN KEY (missionid) REFERENCES missions (missionid)
);

# Problem 1
SELECT missions.missionname, rockets.rocketname, organizations.orgname, launch_sites.sitename, missions.destination, missions.launchyear, missions.outcome
FROM missions
INNER JOIN rockets ON missions.rocketid = rockets.rocketid
INNER JOIN organizations ON rockets.orgid = organizations.orgid
INNER JOIN launch_sites ON missions.siteid = launch_sites.siteid
ORDER BY missions.launchyear DESC, missions.missionname ASC;

# Problem 2
SELECT missions.missionname, rockets.rocketname, payloads.payloadname, payloads.payloadtype, payloads.masskg
FROM payloads
INNER JOIN missions ON payloads.missionid = missions.missionid
INNER JOIN rockets ON missions.rocketid = rockets.rocketid
WHERE missions.launchyear = 2024
ORDER BY payloads.masskg DESC;

# Problem 3
SELECT launch_sites.sitename, missions.missionname, rockets.rocketname, missions.launchyear
FROM launch_sites
LEFT JOIN missions ON launch_sites.siteid = missions.siteid AND missions.launchyear = 2024
LEFT JOIN rockets ON missions.rocketid = rockets.rocketid
ORDER BY launch_sites.sitename ASC, missions.missionname ASC;

# Problem 4
WITH organization_payload_total AS (
	SELECT rockets.orgid, SUM(payloads.masskg) AS total_payload_masskg
    FROM payloads
    INNER JOIN missions ON payloads.missionid = missions.missionid
    INNER JOIN rockets ON missions.rocketid = rockets.rocketid
    GROUP BY rockets.orgid
)
SELECT organizations.orgname, organizations.headquarterscountry, organizations.orgtype, organization_payload_total.total_payload_masskg
FROM organizations
LEFT JOIN organization_payload_total ON organizations.orgid = organization_payload_total.orgid
ORDER BY organization_payload_total.total_payload_masskg DESC;

# Problem 5
WITH country_mission_total AS (
	SELECT launch_sites.countrycode, COUNT(missions.missionid) AS total_missions
    FROM missions
    INNER JOIN launch_sites ON missions.siteid = launch_sites.siteid
    GROUP BY launch_sites.countrycode
),
country_payload_total AS (
	SELECT launch_sites.countrycode, SUM(payloads.masskg) AS total_payload_masskg
    FROM payloads
    INNER JOIN missions ON payloads.missionid = missions.missionid
    INNER JOIN launch_sites ON missions.siteid = launch_sites.siteid
    GROUP BY launch_sites.countrycode
)
SELECT countries.countryname, country_mission_total.total_missions, country_payload_total.total_payload_masskg
FROM countries
LEFT JOIN country_mission_total ON countries.countrycode = country_mission_total.countrycode
LEFT JOIN country_payload_total ON countries.countrycode = country_payload_total.countrycode
ORDER BY country_payload_total.total_payload_masskg DESC;






















