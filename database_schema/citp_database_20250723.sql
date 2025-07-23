
-------------------- PART A: CREATE SEQUENCES --------------------

CREATE SEQUENCE seqexp INCREMENT 20 MINVALUE 10000000 START 10000000;
CREATE SEQUENCE seqallstrains INCREMENT 10 MINVALUE 1000 START 1000;
CREATE SEQUENCE seqallcomps INCREMENT 10 MINVALUE 1000 START 1000;
CREATE SEQUENCE seqthawdates INCREMENT 10 MINVALUE 100000 START 100000;
CREATE SEQUENCE seqwormthaws INCREMENT 10 MINVALUE 100000 START 100000;
CREATE SEQUENCE seqxstrainthaws INCREMENT 10 MINVALUE 1000000 START 1000000;
CREATE SEQUENCE seqxcomps INCREMENT 10 MINVALUE 1000000 START 1000000;
CREATE SEQUENCE seqxreps INCREMENT 10 MINVALUE 10000000 START 10000000;
CREATE SEQUENCE seqxplate INCREMENT 10 MINVALUE 10000000 START 10000000;
CREATE SEQUENCE seqobs INCREMENT 10 MINVALUE 100000000 START 100000000;
CREATE SEQUENCE seqdeaths INCREMENT 10 MINVALUE 100000000 START 100000000;



-------------------- PART B: CREATE TABLES --------------------

CREATE TABLE bacterial_strain_table (
  bacterial_strain_id INT NOT NULL UNIQUE,
  bacterial_strain_name VARCHAR PRIMARY KEY
);

CREATE TABLE experiment_type_table (
  experiment_type_id INT NOT NULL UNIQUE,
  experiment_type_name VARCHAR PRIMARY KEY
);

CREATE TABLE lab_table (
  lab_id INT NOT NULL UNIQUE,
  lab_name VARCHAR PRIMARY KEY
);

CREATE TABLE experiment_table (
  experiment_id INT PRIMARY KEY,
  experiment_name VARCHAR UNIQUE,
  experiment_type_name VARCHAR REFERENCES experiment_type_table,
  bacterial_strain_name VARCHAR REFERENCES bacterial_strain_table,
  lab_name VARCHAR REFERENCES lab_table,
  start_date DATE NOT NULL DEFAULT NOW() - INTERVAL '7 hours',
  temperature DOUBLE PRECISION,
  notes VARCHAR,
  active_exp BOOLEAN NOT NULL DEFAULT TRUE,
  metadata_complete BOOLEAN NOT NULL DEFAULT FALSE,
  experiment_complete BOOLEAN NOT NULL DEFAULT FALSE,
  validated BOOLEAN NOT NULL DEFAULT FALSE,
  flag_for_del BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE manuscript_table (
  manuscript_id INT PRIMARY KEY,
  doi VARCHAR NOT NULL,
  author VARCHAR NOT NULL,
  journal VARCHAR NOT NULL,
  year INT NOT NULL,
  pmid INT
);

CREATE TABLE dataset_table (
  dataset_name VARCHAR PRIMARY KEY,
  manuscript_id INT REFERENCES manuscript_table ON DELETE CASCADE,
  dataset_description TEXT,
  display_order INT,
  comp_sort_order INT
);

CREATE TABLE xdatasets (
  dataset_name VARCHAR REFERENCES dataset_table ON DELETE CASCADE,
  experiment_id INT,
  experiment_type_name VARCHAR
);

CREATE TABLE species_table (
  species_id INT NOT NULL UNIQUE,
  species_name VARCHAR PRIMARY KEY
);

CREATE TABLE all_strains_table (
  strain_id INT PRIMARY KEY,
  strain_name VARCHAR NOT NULL UNIQUE,
  background VARCHAR,
  genotype VARCHAR,
  species_name VARCHAR REFERENCES species_table,
  active_strain BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE thaw_dates_table (
  thaw_date_id INT PRIMARY KEY,
  thaw_date DATE NOT NULL,
  lab_name VARCHAR REFERENCES lab_table,
  active_date BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE worm_thaws_table (
  worm_thaw_id INT PRIMARY KEY,
  active_thaw BOOLEAN NOT NULL DEFAULT TRUE,
  freeze_date DATE NOT NULL,
  strain_id INT REFERENCES all_strains_table ON DELETE CASCADE,
  thaw_date_id INT REFERENCES thaw_dates_table ON DELETE CASCADE
);

CREATE TABLE compound_controls_table (
  control_id INT NOT NULL UNIQUE,
  control_name VARCHAR PRIMARY KEY
);

CREATE TABLE all_compounds_table (
  comp_id INT PRIMARY KEY,
  comp_name VARCHAR NOT NULL UNIQUE,
  comp_abbr VARCHAR NOT NULL UNIQUE,
  active_comp BOOLEAN NOT NULL DEFAULT TRUE,
  control_name VARCHAR REFERENCES compound_controls_table ON DELETE CASCADE
);

CREATE TABLE compound_reference_table (
  comp_ref_id INT PRIMARY KEY,
  alternate_comp_name VARCHAR NOT NULL UNIQUE,
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE
);

CREATE TABLE compound_metadata_table (
  comp_display_name VARCHAR NOT NULL UNIQUE,
  pubchem_id INT,
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE
);

CREATE TABLE experimental_conditions_table (
  exp_cond_id INT PRIMARY KEY,
  exp_cond_name VARCHAR NOT NULL UNIQUE,
  active_exp_cond BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE xstrainthaws (
  xstrain_id INT PRIMARY KEY,
  egg_lay_date DATE NOT NULL,
  experiment_id INT REFERENCES experiment_table ON DELETE CASCADE,
  worm_thaw_id INT REFERENCES worm_thaws_table ON DELETE CASCADE
);

CREATE TABLE xcomps (
  xcomp_id INT PRIMARY KEY,
  concentration DOUBLE PRECISION NOT NULL,
  concentration_units VARCHAR NOT NULL,
  total_replicates INT DEFAULT 1 NOT NULL,
  exp_cond_id INT DEFAULT 1 REFERENCES experimental_conditions_table ON DELETE CASCADE,
  experiment_id INT REFERENCES experiment_table ON DELETE CASCADE, 
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE
);

CREATE TABLE xreps (
  xrep_id INT PRIMARY KEY,
  replicate_num INT,
  xcomp_id INT REFERENCES xcomps ON DELETE CASCADE
);

CREATE TABLE tech_table (
  tech_initial VARCHAR PRIMARY KEY,
  tech_name VARCHAR,
  tech_id INT NOT NULL UNIQUE,
  active_tech BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE plate_table (
  plate_id INT PRIMARY KEY,
  plate_name VARCHAR,
  tech_initial VARCHAR REFERENCES tech_table DEFAULT 'UN',
  validated BOOLEAN NOT NULL DEFAULT FALSE,
  exclude_from_export BOOLEAN NOT NULL DEFAULT FALSE,
  hide_plate BOOLEAN NOT NULL DEFAULT FALSE,
  xrep_id INT REFERENCES xreps ON DELETE CASCADE,
  xstrain_id INT REFERENCES xstrainthaws ON DELETE CASCADE
);

CREATE TABLE observation_table (
  observation_id INT PRIMARY KEY,
  plate_id INT REFERENCES plate_table ON DELETE CASCADE,
  death_age DOUBLE PRECISION,
  observation_date DATE DEFAULT NOW() - INTERVAL '7 hours',
  alive INT,
  dead INT,
  censor INT,
  lost INT,
  wall INT,
  bag INT,
  extrusion INT,
  notes VARCHAR,
  validated BOOLEAN DEFAULT FALSE,
  del BOOLEAN DEFAULT FALSE
);

CREATE TABLE death_table (
  death_id INT PRIMARY KEY,
  observation_id INT REFERENCES observation_table ON DELETE CASCADE,
  indiv_death INT CHECK(indiv_death IN (1, 0)),
  indiv_censor INT CHECK(indiv_censor IN (1, 0)),
  censor_type VARCHAR
);

CREATE TABLE experiment_alm_alias_table (
  experiment_id INT NOT NULL REFERENCES experiment_table ON DELETE CASCADE,
  experiment_alias VARCHAR NOT NULL
);

CREATE TABLE plate_alm_supp_table (
  plate_id INT NOT NULL REFERENCES plate_table ON DELETE CASCADE,
  device VARCHAR,
  plate_row INT,
  plate_column VARCHAR,
  total_worms INT,
  age_of_adult INT
);

CREATE TABLE death_alm_supp_table (
  death_id INT NOT NULL REFERENCES death_table ON DELETE CASCADE,
  duration_not_fast_moving DOUBLE PRECISION
);

CREATE TABLE celest_experiment_table (
  celest_experiment_id INT PRIMARY KEY,
  experiment_name VARCHAR UNIQUE,
  celest_egg_lay_date DATE NOT NULL,
  lab_name VARCHAR REFERENCES lab_table,
  notes VARCHAR,
  flag_for_del BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE celest_date_table (
  celest_date_id INT PRIMARY KEY,
  celest_experiment_id INT REFERENCES celest_experiment_table ON DELETE CASCADE,
  celest_date DATE NOT NULL,
  adult_age INT NOT NULL
);

CREATE TABLE celest_xstraincomps (
  celest_xstraincomp_id INT PRIMARY KEY,
  celest_date_id INT REFERENCES celest_date_table ON DELETE CASCADE,
  strain_id INT REFERENCES all_strains_table ON DELETE CASCADE,
  comp_id INT REFERENCES all_compounds_table ON DELETE CASCADE,
  tech_initial VARCHAR REFERENCES tech_table DEFAULT 'UN',
  trial_number INT NOT NULL
);

CREATE TABLE celest_video_table (
  celest_video_id INT PRIMARY KEY,
  celest_xstraincomp_id INT REFERENCES celest_xstraincomps ON DELETE CASCADE,
  video_name VARCHAR NOT NULL
);

CREATE TABLE celest_worm_measurement_table (
  celest_worm_measurement_id INT PRIMARY KEY,
  celest_video_id INT REFERENCES celest_video_table ON DELETE CASCADE,
  worm_number INT NOT NULL,
  wave_init_rate DOUBLE PRECISION NOT NULL, 
  body_wave_number DOUBLE PRECISION NOT NULL,
  asymmetry DOUBLE PRECISION NOT NULL,
  stretch DOUBLE PRECISION NOT NULL,
  curling DOUBLE PRECISION NOT NULL,
  travel_speed DOUBLE PRECISION NOT NULL,
  brush_stroke DOUBLE PRECISION NOT NULL,
  activity_index DOUBLE PRECISION NOT NULL
);

CREATE TABLE clone_observations_log (
  from_plate_item VARCHAR,
  to_plate_list VARCHAR,
  tech_initial VARCHAR,
  time_of_operation VARCHAR
);



ALTER TABLE experiment_table ALTER COLUMN experiment_id SET DEFAULT nextval('seqexp');
ALTER TABLE all_strains_table ALTER COLUMN strain_id SET DEFAULT nextval('seqallstrains');
ALTER TABLE thaw_dates_table ALTER COLUMN thaw_date_id SET DEFAULT nextval('seqthawdates');
ALTER TABLE worm_thaws_table ALTER COLUMN worm_thaw_id SET DEFAULT nextval('seqwormthaws');
ALTER TABLE all_compounds_table ALTER COLUMN comp_id SET DEFAULT nextval('seqallcomps');
ALTER TABLE xstrainthaws ALTER COLUMN xstrain_id SET DEFAULT nextval('seqxstrainthaws');
ALTER TABLE xcomps ALTER COLUMN xcomp_id SET DEFAULT nextval('seqxcomps');
ALTER TABLE xreps ALTER COLUMN xrep_id SET DEFAULT nextval('seqxreps');
ALTER TABLE plate_table ALTER COLUMN plate_id SET DEFAULT nextval('seqxplate');
ALTER TABLE observation_table ALTER COLUMN observation_id SET DEFAULT nextval('seqobs');
ALTER TABLE death_table ALTER COLUMN death_id SET DEFAULT nextval('seqdeaths');



-------------------- PART C: CREATE FUNCTIONS AND TRIGGERS --------------------

-- Update death records related to an observation.
CREATE FUNCTION updateDeaths()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  DELETE FROM death_table WHERE (observation_id=NEW.observation_id AND indiv_death=1);
  FOR i IN 1..NEW.Dead LOOP
    INSERT INTO death_table(observation_id, indiv_death, indiv_censor)
    VALUES(NEW.observation_id, 1, 0);
  END LOOP;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER updateDeaths
  BEFORE INSERT OR UPDATE OF dead ON observation_table
  FOR EACH ROW
  EXECUTE PROCEDURE updateDeaths();

-- Calculate censored value and update censored records related to an observation.
CREATE FUNCTION updateCensored()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  NEW.Censor = NEW.Lost + NEW.Wall + NEW.Bag + NEW.Extrusion;
  DELETE FROM death_table WHERE (observation_id=NEW.observation_id AND indiv_censor=1);
  FOR i IN 1..NEW.Censor LOOP
    INSERT INTO death_table(observation_id, indiv_death, indiv_censor)
    VALUES(NEW.observation_id, 0, 1);
  END LOOP;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER updateCensored
  BEFORE INSERT OR UPDATE OF censor, lost, wall, bag, extrusion ON observation_table
  FOR EACH ROW
  EXECUTE PROCEDURE updateCensored();

-- Create new xreps whenever a new xcomps record is created.
CREATE FUNCTION addReps()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  DELETE FROM xreps WHERE xcomp_id=NEW.xcomp_id;
  FOR i IN 1..NEW.total_replicates LOOP
    INSERT INTO xreps(xcomp_id, replicate_num)
    VALUES(NEW.xcomp_id, i);
  END LOOP;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER addReps
  AFTER INSERT OR UPDATE OF total_replicates ON xcomps
  FOR EACH ROW
  EXECUTE PROCEDURE addReps();

-- Calculate adult age when entering an observation date for a manual experiment.
CREATE FUNCTION updateDeathAge()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  NEW.death_age := (SELECT (NEW.observation_date - experiment_table.start_date) FROM experiment_table, xstrainthaws, plate_table, observation_table WHERE (observation_table.plate_id = plate_table.plate_id AND plate_table.xstrain_id = xstrainthaws.xstrain_id AND xstrainthaws.experiment_id = experiment_table.experiment_id  AND observation_table.observation_id = NEW.observation_id));
  RETURN NEW;
END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER updateDeathAge
  BEFORE INSERT OR UPDATE OF observation_date, observation_id ON observation_table
  FOR EACH ROW
  EXECUTE PROCEDURE updateDeathAge();



-------------------- PART D: CREATE VIEWS --------------------

CREATE VIEW all_compounds AS
 SELECT all_compounds_table.comp_id AS "Compound ID",
    all_compounds_table.comp_name AS "Compound",
    all_compounds_table.comp_abbr AS "Abbrev",
    all_compounds_table.control_name AS "Control",
    all_compounds_table.active_comp AS "Active"
   FROM all_compounds_table
   ORDER BY all_compounds_table.comp_id;

CREATE VIEW all_experiments AS
 SELECT experiment_table.experiment_id AS "ID",
    experiment_table.experiment_name AS "Name",
    experiment_table.experiment_type_name AS "Type",
    experiment_table.bacterial_strain_name AS "Bac Strain",
    experiment_table.lab_name AS "Lab",
    experiment_table.start_date AS "Start Date",
    experiment_table.active_exp AS "Active",
    experiment_table.metadata_complete AS "Metadata Complete",
    experiment_table.experiment_complete AS "Experiment Complete",
    experiment_table.validated AS "Experiment Validated"
   FROM experiment_table
   ORDER BY experiment_table.experiment_id;

CREATE VIEW all_species AS
 SELECT species_table.species_id AS "Species ID",
    species_table.species_name AS "Species Name"
   FROM species_table
   ORDER BY species_table.species_id;

CREATE VIEW all_strains AS
 SELECT all_strains_table.strain_id AS "Strain ID",
    all_strains_table.strain_name AS "Strain",
    all_strains_table.species_name AS "Species",
    all_strains_table.background AS "Background",
    all_strains_table.genotype AS "Genotype",
    all_strains_table.active_strain AS "Active"
   FROM all_strains_table
   ORDER BY all_strains_table.strain_id;

CREATE VIEW all_exp_conditions AS
 SELECT experimental_conditions_table.exp_cond_id AS "Exp Cond ID",
    experimental_conditions_table.exp_cond_name AS "Exp Cond Name",
    experimental_conditions_table.active_exp_cond AS "Active"
   FROM experimental_conditions_table
   ORDER BY experimental_conditions_table.exp_cond_id;

CREATE VIEW all_thaw_dates AS
 SELECT thaw_dates_table.thaw_date_id AS "Thaw Date ID",
    thaw_dates_table.thaw_date AS "Thaw Date",
    thaw_dates_table.lab_name AS "Lab",
    thaw_dates_table.active_date AS "Active"
   FROM thaw_dates_table
   ORDER BY thaw_dates_table.thaw_date DESC, thaw_dates_table.thaw_date_id ASC;

CREATE VIEW all_worm_thaws AS
 SELECT worm_thaws_table.worm_thaw_id AS "Thaw ID",
    worm_thaws_table.active_thaw AS "Active",
    thaw_dates_table.thaw_date AS "Thaw Date",
    worm_thaws_table.freeze_date AS "Freeze Date",
    thaw_dates_table.lab_name AS "Lab",
    all_strains_table.strain_name AS "Strain"
   FROM worm_thaws_table,
    all_strains_table,
    thaw_dates_table
   WHERE ( (worm_thaws_table.thaw_date_id = thaw_dates_table.thaw_date_id) AND (worm_thaws_table.strain_id = all_strains_table.strain_id) )
   ORDER BY thaw_dates_table.thaw_date DESC, worm_thaws_table.worm_thaw_id ASC;

CREATE VIEW all_plates AS
  SELECT plate_table.plate_id AS "Plate ID",
     experiment_table.experiment_name AS "Exp Name",
     xreps.replicate_num AS "Replicate",
     all_strains_table.strain_name AS "Strain",
     all_compounds_table.comp_name AS "Compound",
     xcomps.concentration AS "Conc",
     xcomps.concentration_units AS "Units",
     experimental_conditions_table.exp_cond_name AS "Condition",
     plate_table.validated AS "Done",
     plate_alm_supp_table.device AS "Scanner"
    FROM (plate_table
      LEFT JOIN plate_alm_supp_table ON ((plate_table.plate_id = plate_alm_supp_table.plate_id))),
     experiment_table,
     xstrainthaws,
     xreps,
     worm_thaws_table,
     all_strains_table,
     xcomps,
     all_compounds_table,
     experimental_conditions_table
   WHERE ((plate_table.xstrain_id = xstrainthaws.xstrain_id) AND (xstrainthaws.experiment_id = experiment_table.experiment_id) AND (plate_table.xrep_id = xreps.xrep_id) AND (xstrainthaws.worm_thaw_id = worm_thaws_table.worm_thaw_id) AND (worm_thaws_table.strain_id = all_strains_table.strain_id) AND (xreps.xcomp_id = xcomps.xcomp_id) AND (xcomps.comp_id = all_compounds_table.comp_id) AND (xcomps.exp_cond_id = experimental_conditions_table.exp_cond_id))
   ORDER BY plate_table.plate_id;

CREATE VIEW observations_for_plate AS
  SELECT observation_table.observation_id AS "Obs ID",
     observation_table.plate_id AS "Plate ID",
     observation_table.del AS "Del",
     observation_table.death_age AS "Age",
     observation_table.observation_date AS "Date",
     observation_table.alive AS "Alive",
     observation_table.dead AS "Dead",
     observation_table.censor AS "Censor",
     observation_table.lost AS "Lost",
     observation_table.wall AS "Wall", -- omit this line in citp-legacy
     observation_table.bag AS "Bag",
     observation_table.extrusion AS "Extrusion",
     observation_table.notes AS "Notes",
     observation_table.validated AS "Validated"
    FROM observation_table
   ORDER BY observation_table.plate_id, observation_table.observation_date DESC;

CREATE VIEW compounds_for_experiment AS
 SELECT xcomps.concentration AS "Conc",
    xcomps.concentration_units AS "Units",
    xcomps.total_replicates AS "Reps",
    all_compounds_table.comp_name AS "Compound Name",
    experimental_conditions_table.exp_cond_name AS "Condition",
    xcomps.xcomp_id AS "ID",
    xcomps.experiment_id AS "Exp ID"
   FROM xcomps,
   all_compounds_table,
   experimental_conditions_table
   WHERE (xcomps.exp_cond_id = experimental_conditions_table.exp_cond_id AND xcomps.comp_id = all_compounds_table.comp_id)
   ORDER BY xcomps.xcomp_id;

CREATE VIEW strain_thaws_for_experiment AS
 SELECT xstrainthaws.egg_lay_date AS "Egg Lay",
    all_strains_table.strain_name AS "Strain",
    thaw_dates_table.thaw_date AS "Thaw Date",
    worm_thaws_table.freeze_date AS "Freeze Date",
    thaw_dates_table.lab_name AS "Lab",
    xstrainthaws.experiment_id AS "Experiment ID",
    xstrainthaws.worm_thaw_id AS "Worm Thaw ID",
    xstrainthaws.xstrain_id AS "ID"
   FROM xstrainthaws,
    thaw_dates_table,
    all_strains_table,
    worm_thaws_table
   WHERE (xstrainthaws.worm_thaw_id = worm_thaws_table.worm_thaw_id AND worm_thaws_table.strain_id = all_strains_table.strain_id AND worm_thaws_table.thaw_date_id = thaw_dates_table.thaw_date_id)
   ORDER BY xstrainthaws.xstrain_id;

CREATE VIEW plates_for_experiment AS
 SELECT plate_table.plate_id AS "Plate ID",
    plate_table.xrep_id AS "Rep ID",
    plate_table.xstrain_id AS "Strain ID",
    plate_table.plate_name AS "Plate Name",
    plate_table.tech_initial AS "Tech",
    all_strains_table.strain_name AS "Strain",
    experiment_table.experiment_id AS "Exp ID",
    xreps.replicate_num AS "Rep",
    xcomps.concentration AS "Conc",
    xcomps.concentration_units AS "Units",
    all_compounds_table.comp_name AS "Compound",
    experimental_conditions_table.exp_cond_name AS "Condition",
    plate_table.validated AS "Done",
    plate_table.hide_plate AS "Remove",
    plate_alm_supp_table.device AS "Scanner"
   FROM (plate_table
     LEFT JOIN plate_alm_supp_table ON ((plate_table.plate_id = plate_alm_supp_table.plate_id))),
    xstrainthaws,
    worm_thaws_table,
    all_strains_table,
    experiment_table,
    xreps,
    xcomps,
    all_compounds_table,
    experimental_conditions_table
   WHERE ((plate_table.xstrain_id = xstrainthaws.xstrain_id AND xstrainthaws.worm_thaw_id = worm_thaws_table.worm_thaw_id AND worm_thaws_table.strain_id = all_strains_table.strain_id AND xstrainthaws.experiment_id = experiment_table.experiment_id) AND (plate_table.xrep_id = xreps.xrep_id AND xreps.xcomp_id = xcomps.xcomp_id AND xcomps.comp_id = all_compounds_table.comp_id AND xcomps.exp_cond_id = experimental_conditions_table.exp_cond_id))
   ORDER BY xreps.replicate_num, plate_table.xstrain_id, all_compounds_table.comp_name, xcomps.concentration, plate_table.plate_id;

CREATE VIEW celest_strain_comps_for_experiment AS
 SELECT DISTINCT celest_date_table.celest_experiment_id AS "CeleST ID",
    celest_date_table.celest_date_id AS "Date ID",
    celest_date_table.celest_date AS "CeleST Date",
    celest_date_table.adult_age AS "Age",
    all_strains_table.strain_name AS "Strain",
    all_compounds_table.comp_name AS "Compound",
    celest_xstraincomps.trial_number AS "Trial"
   FROM celest_date_table,
    celest_xstraincomps,
    all_strains_table,
    all_compounds_table
   WHERE ((celest_date_table.celest_date_id = celest_xstraincomps.celest_date_id) AND (celest_xstraincomps.strain_id = all_strains_table.strain_id) AND (celest_xstraincomps.comp_id = all_compounds_table.comp_id))
   ORDER BY celest_date_table.celest_date;

CREATE VIEW all_data_download_format AS
 SELECT t1.experiment_name AS "Experiment",
    t1.indiv_death AS "Dead",
    t1.indiv_censor AS "Censor",
    t1.death_age AS "DeathAge",
    t2.death_age AS "DeathNoCen",
    t1.observation_date AS "ObsDate",
    (((((t1.lost || ' lost, '::text) || t1.bag) || ' bag, '::text) || t1.extrusion) || ' ext.'::text) AS "ObsReason",
    t1.start_date AS "StartDate",
    t1.notes AS "ObsNote",
    t1.plate_name AS "Plate",
    t1.device AS "Scanner",
    ((t1.plate_column_upper || ':'::text) || t1.plate_row) AS "Plate Location",
    t1.total_worms AS "Total Worms",
    t1.strain_name AS "Strain",
    t1.species_name AS "Species",
    t1.tech_id AS "Tech ID",
    t1.lab_name AS "Lab",
    t1.replicate_num AS "Rep",
    t1.comp_name AS "Compound",
    t1.concentration AS "Concentration",
    t1.concentration_units AS "Units",
    t1.exp_cond_name AS "Condition",
    t1.death_id,
    t1.observation_id,
    t1.plate_id,
    t1.experiment_id
   FROM (( SELECT death_table.indiv_death,
            death_table.indiv_censor,
            observation_table.death_age,
            observation_table.notes,
            experiment_table.start_date,
            observation_table.observation_date,
            plate_table.plate_name,
            experiment_table.experiment_name,
            all_strains_table.strain_name,
            all_strains_table.species_name,
            plate_alm_supp_table.device,
            plate_alm_supp_table.plate_row,
            upper((plate_alm_supp_table.plate_column)::text) AS plate_column_upper,
            plate_alm_supp_table.total_worms,
            tech_table.tech_id,
            experiment_table.lab_name,
            experiment_table.experiment_type_name,
            xreps.replicate_num,
            xcomps.concentration,
            xcomps.concentration_units,
            experimental_conditions_table.exp_cond_name,
            all_compounds_table.comp_name,
            death_table.death_id,
            observation_table.observation_id,
            plate_table.plate_id,
            experiment_table.experiment_id,
            observation_table.lost,
            observation_table.bag,
            observation_table.extrusion
           FROM death_table,
            observation_table,
            (plate_table
             LEFT JOIN plate_alm_supp_table ON ((plate_table.plate_id = plate_alm_supp_table.plate_id))),
            xstrainthaws,
            experiment_table,
            worm_thaws_table,
            all_strains_table,
            tech_table,
            xreps,
            xcomps,
            experimental_conditions_table,
            all_compounds_table
          WHERE ((death_table.observation_id = observation_table.observation_id) AND (observation_table.plate_id = plate_table.plate_id) AND (plate_table.xstrain_id = xstrainthaws.xstrain_id) AND (xstrainthaws.experiment_id = experiment_table.experiment_id) AND (xstrainthaws.worm_thaw_id = worm_thaws_table.worm_thaw_id) AND (worm_thaws_table.strain_id = all_strains_table.strain_id) AND ((plate_table.tech_initial)::text = (tech_table.tech_initial)::text) AND (plate_table.xrep_id = xreps.xrep_id) AND (xreps.xcomp_id = xcomps.xcomp_id) AND (xcomps.exp_cond_id = experimental_conditions_table.exp_cond_id) AND (xcomps.comp_id = all_compounds_table.comp_id))
          ORDER BY plate_table.plate_id, observation_table.observation_date) t1
     LEFT JOIN ( SELECT observation_table.death_age,
            death_table.indiv_death,
            death_table.death_id
           FROM observation_table,
            death_table
          WHERE ((observation_table.observation_id = death_table.observation_id) AND (death_table.indiv_death = 1))) t2 ON ((t1.death_id = t2.death_id)))
  ORDER BY t1.experiment_id, t1.plate_id, t1.observation_id, t1.death_id;
