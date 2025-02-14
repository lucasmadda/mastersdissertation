-- mimiciii.vitals_hourly_lm source

CREATE MATERIALIZED VIEW mimiciii.vitals_hourly_lm
TABLESPACE pg_default
AS WITH t2 AS (
         WITH t1 AS (
                 SELECT ie.subject_id,
                    ie.hadm_id,
                    ie.icustay_id,
                    ce.charttime,
                        CASE
                            WHEN (ce.itemid = ANY (ARRAY[211, 220045])) AND ce.valuenum > 0::double precision AND ce.valuenum < 300::double precision THEN 1
                            WHEN (ce.itemid = ANY (ARRAY[51, 442, 455, 6701, 220179, 220050])) AND ce.valuenum > 0::double precision AND ce.valuenum < 400::double precision THEN 2
                            WHEN (ce.itemid = ANY (ARRAY[8368, 8440, 8441, 8555, 220180, 220051])) AND ce.valuenum > 0::double precision AND ce.valuenum < 300::double precision THEN 3
                            WHEN (ce.itemid = ANY (ARRAY[456, 52, 6702, 443, 220052, 220181, 225312])) AND ce.valuenum > 0::double precision AND ce.valuenum < 300::double precision THEN 4
                            WHEN (ce.itemid = ANY (ARRAY[615, 618, 220210, 224690])) AND ce.valuenum > 0::double precision AND ce.valuenum < 70::double precision THEN 5
                            WHEN (ce.itemid = ANY (ARRAY[223761, 678])) AND ce.valuenum > 70::double precision AND ce.valuenum < 120::double precision THEN 6
                            WHEN (ce.itemid = ANY (ARRAY[223762, 676])) AND ce.valuenum > 10::double precision AND ce.valuenum < 50::double precision THEN 6
                            WHEN (ce.itemid = ANY (ARRAY[646, 220277])) AND ce.valuenum > 0::double precision AND ce.valuenum <= 100::double precision THEN 7
                            WHEN (ce.itemid = ANY (ARRAY[807, 811, 1529, 3745, 3744, 225664, 220621, 226537])) AND ce.valuenum > 0::double precision THEN 8
                            ELSE NULL::integer
                        END AS vitalid,
                        CASE
                            WHEN ce.itemid = ANY (ARRAY[223761, 678]) THEN (ce.valuenum - 32::double precision) / 1.8::double precision
                            ELSE ce.valuenum
                        END AS valuenum
                   FROM mimiciii.icustays ie
                     LEFT JOIN mimiciii.chartevents ce ON ie.icustay_id = ce.icustay_id AND (ce.error IS NULL OR ce.error = 0)
                  WHERE ce.itemid = ANY (ARRAY[211, 220045, 51, 442, 455, 6701, 220179, 220050, 8368, 8440, 8441, 8555, 220180, 220051, 456, 52, 6702, 443, 220052, 220181, 225312, 618, 615, 220210, 224690, 646, 220277, 807, 811, 1529, 3745, 3744, 225664, 220621, 226537, 223762, 676, 223761, 678])
                )
         SELECT t1.subject_id,
            t1.hadm_id,
            ih.hr,
            t1.icustay_id,
            t1.vitalid,
            t1.valuenum
           FROM t1
             LEFT JOIN mimiciii.icustay_hours ih ON t1.icustay_id = ih.icustay_id AND t1.charttime >= (ih.endtime - '01:00:00'::interval) AND t1.charttime < ih.endtime
        )
 SELECT subject_id,
    hadm_id,
    icustay_id,
    hr,
    min(
        CASE
            WHEN vitalid = 1 THEN valuenum
            ELSE NULL::double precision
        END) AS heartrate_min,
    max(
        CASE
            WHEN vitalid = 1 THEN valuenum
            ELSE NULL::double precision
        END) AS heartrate_max,
    avg(
        CASE
            WHEN vitalid = 1 THEN valuenum
            ELSE NULL::double precision
        END) AS heartrate_mean,
    min(
        CASE
            WHEN vitalid = 2 THEN valuenum
            ELSE NULL::double precision
        END) AS sysbp_min,
    max(
        CASE
            WHEN vitalid = 2 THEN valuenum
            ELSE NULL::double precision
        END) AS sysbp_max,
    avg(
        CASE
            WHEN vitalid = 2 THEN valuenum
            ELSE NULL::double precision
        END) AS sysbp_mean,
    min(
        CASE
            WHEN vitalid = 3 THEN valuenum
            ELSE NULL::double precision
        END) AS diasbp_min,
    max(
        CASE
            WHEN vitalid = 3 THEN valuenum
            ELSE NULL::double precision
        END) AS diasbp_max,
    avg(
        CASE
            WHEN vitalid = 3 THEN valuenum
            ELSE NULL::double precision
        END) AS diasbp_mean,
    min(
        CASE
            WHEN vitalid = 4 THEN valuenum
            ELSE NULL::double precision
        END) AS meanbp_min,
    max(
        CASE
            WHEN vitalid = 4 THEN valuenum
            ELSE NULL::double precision
        END) AS meanbp_max,
    avg(
        CASE
            WHEN vitalid = 4 THEN valuenum
            ELSE NULL::double precision
        END) AS meanbp_mean,
    min(
        CASE
            WHEN vitalid = 5 THEN valuenum
            ELSE NULL::double precision
        END) AS resprate_min,
    max(
        CASE
            WHEN vitalid = 5 THEN valuenum
            ELSE NULL::double precision
        END) AS resprate_max,
    avg(
        CASE
            WHEN vitalid = 5 THEN valuenum
            ELSE NULL::double precision
        END) AS resprate_mean,
    min(
        CASE
            WHEN vitalid = 6 THEN valuenum
            ELSE NULL::double precision
        END) AS tempc_min,
    max(
        CASE
            WHEN vitalid = 6 THEN valuenum
            ELSE NULL::double precision
        END) AS tempc_max,
    avg(
        CASE
            WHEN vitalid = 6 THEN valuenum
            ELSE NULL::double precision
        END) AS tempc_mean,
    min(
        CASE
            WHEN vitalid = 7 THEN valuenum
            ELSE NULL::double precision
        END) AS spo2_min,
    max(
        CASE
            WHEN vitalid = 7 THEN valuenum
            ELSE NULL::double precision
        END) AS spo2_max,
    avg(
        CASE
            WHEN vitalid = 7 THEN valuenum
            ELSE NULL::double precision
        END) AS spo2_mean,
    min(
        CASE
            WHEN vitalid = 8 THEN valuenum
            ELSE NULL::double precision
        END) AS glucose_min,
    max(
        CASE
            WHEN vitalid = 8 THEN valuenum
            ELSE NULL::double precision
        END) AS glucose_max,
    avg(
        CASE
            WHEN vitalid = 8 THEN valuenum
            ELSE NULL::double precision
        END) AS glucose_mean
   FROM t2
  WHERE hr IS NOT NULL
  GROUP BY subject_id, hadm_id, icustay_id, hr
  ORDER BY subject_id, hadm_id, icustay_id, hr
WITH DATA;

-- mimiciii.blood_gas_hourly_lm source

CREATE MATERIALIZED VIEW mimiciii.blood_gas_hourly_lm
TABLESPACE pg_default
AS WITH t2 AS (
         WITH t1 AS (
                 SELECT ie.subject_id,
                    ie.hadm_id,
                    ie.icustay_id,
                        CASE
                            WHEN le.charttime >= mimiciii.datetime_sub(ie.intime, '06:00:00'::interval hour) AND le.charttime <= ie.intime THEN ie.intime
                            ELSE le.charttime
                        END AS charttime,
                        CASE
                            WHEN le.itemid = 50800 THEN 'SPECIMEN'::text
                            WHEN le.itemid = 50801 THEN 'AADO2'::text
                            WHEN le.itemid = 50802 THEN 'BASEEXCESS'::text
                            WHEN le.itemid = 50803 THEN 'BICARBONATE'::text
                            WHEN le.itemid = 50804 THEN 'TOTALCO2'::text
                            WHEN le.itemid = 50805 THEN 'CARBOXYHEMOGLOBIN'::text
                            WHEN le.itemid = 50806 THEN 'CHLORIDE'::text
                            WHEN le.itemid = 50808 THEN 'CALCIUM'::text
                            WHEN le.itemid = 50809 THEN 'GLUCOSE'::text
                            WHEN le.itemid = 50810 THEN 'HEMATOCRIT'::text
                            WHEN le.itemid = 50811 THEN 'HEMOGLOBIN'::text
                            WHEN le.itemid = 50812 THEN 'INTUBATED'::text
                            WHEN le.itemid = 50813 THEN 'LACTATE'::text
                            WHEN le.itemid = 50814 THEN 'METHEMOGLOBIN'::text
                            WHEN le.itemid = 50815 THEN 'O2FLOW'::text
                            WHEN le.itemid = 50816 THEN 'FIO2'::text
                            WHEN le.itemid = 50817 THEN 'SO2'::text
                            WHEN le.itemid = 50818 THEN 'PCO2'::text
                            WHEN le.itemid = 50819 THEN 'PEEP'::text
                            WHEN le.itemid = 50820 THEN 'PH'::text
                            WHEN le.itemid = 50821 THEN 'PO2'::text
                            WHEN le.itemid = 50822 THEN 'POTASSIUM'::text
                            WHEN le.itemid = 50823 THEN 'REQUIREDO2'::text
                            WHEN le.itemid = 50824 THEN 'SODIUM'::text
                            WHEN le.itemid = 50825 THEN 'TEMPERATURE'::text
                            WHEN le.itemid = 50826 THEN 'TIDALVOLUME'::text
                            WHEN le.itemid = 50827 THEN 'VENTILATIONRATE'::text
                            WHEN le.itemid = 50828 THEN 'VENTILATOR'::text
                            ELSE NULL::text
                        END AS label,
                    le.value,
                        CASE
                            WHEN le.valuenum <= 0::double precision AND le.itemid <> 50802 THEN NULL::double precision
                            WHEN le.itemid = 50810 AND le.valuenum > 100::double precision THEN NULL::double precision
                            WHEN le.itemid = 50816 AND le.valuenum < 20::double precision THEN NULL::double precision
                            WHEN le.itemid = 50816 AND le.valuenum > 100::double precision THEN NULL::double precision
                            WHEN le.itemid = 50817 AND le.valuenum > 100::double precision THEN NULL::double precision
                            WHEN le.itemid = 50815 AND le.valuenum > 70::double precision THEN NULL::double precision
                            WHEN le.itemid = 50821 AND le.valuenum > 800::double precision THEN NULL::double precision
                            ELSE le.valuenum
                        END AS valuenum
                   FROM mimiciii.icustays ie
                     LEFT JOIN mimiciii.labevents le ON le.subject_id = ie.subject_id AND le.hadm_id = ie.hadm_id AND le.charttime >= mimiciii.datetime_sub(ie.intime, '06:00:00'::interval hour) AND le.charttime <= ie.outtime AND (le.itemid = ANY (ARRAY[50800, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809, 50810, 50811, 50812, 50813, 50814, 50815, 50816, 50817, 50818, 50819, 50820, 50821, 50822, 50823, 50824, 50825, 50826, 50827, 50828, 51545]))
                )
         SELECT t1.subject_id,
            t1.hadm_id,
            ih.hr,
            t1.icustay_id,
            t1.label,
            t1.value,
            t1.valuenum
           FROM t1
             LEFT JOIN mimiciii.icustay_hours ih ON t1.icustay_id = ih.icustay_id AND t1.charttime >= (ih.endtime - '01:00:00'::interval) AND t1.charttime < ih.endtime
        )
 SELECT subject_id,
    hadm_id,
    icustay_id,
    hr,
    max(
        CASE
            WHEN label = 'SPECIMEN'::text THEN value
            ELSE NULL::character varying
        END::text) AS specimen,
    max(
        CASE
            WHEN label = 'AADO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS aado2,
    max(
        CASE
            WHEN label = 'BASEEXCESS'::text THEN valuenum
            ELSE NULL::double precision
        END) AS baseexcess,
    max(
        CASE
            WHEN label = 'BICARBONATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bicarbonate,
    max(
        CASE
            WHEN label = 'TOTALCO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS totalco2,
    max(
        CASE
            WHEN label = 'CARBOXYHEMOGLOBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS carboxyhemoglobin,
    max(
        CASE
            WHEN label = 'CHLORIDE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS chloride,
    max(
        CASE
            WHEN label = 'CALCIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS calcium,
    max(
        CASE
            WHEN label = 'GLUCOSE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS glucose,
    max(
        CASE
            WHEN label = 'HEMATOCRIT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hematocrit,
    max(
        CASE
            WHEN label = 'HEMOGLOBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hemoglobin,
    max(
        CASE
            WHEN label = 'INTUBATED'::text THEN valuenum
            ELSE NULL::double precision
        END) AS intubated,
    max(
        CASE
            WHEN label = 'LACTATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS lactate,
    max(
        CASE
            WHEN label = 'METHEMOGLOBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS methemoglobin,
    max(
        CASE
            WHEN label = 'O2FLOW'::text THEN valuenum
            ELSE NULL::double precision
        END) AS o2flow,
    max(
        CASE
            WHEN label = 'FIO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS fio2,
    max(
        CASE
            WHEN label = 'SO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS so2,
    max(
        CASE
            WHEN label = 'PCO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS pco2,
    max(
        CASE
            WHEN label = 'PEEP'::text THEN valuenum
            ELSE NULL::double precision
        END) AS peep,
    max(
        CASE
            WHEN label = 'PH'::text THEN valuenum
            ELSE NULL::double precision
        END) AS ph,
    max(
        CASE
            WHEN label = 'PO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS po2,
    max(
        CASE
            WHEN label = 'POTASSIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS potassium,
    max(
        CASE
            WHEN label = 'REQUIREDO2'::text THEN valuenum
            ELSE NULL::double precision
        END) AS requiredo2,
    max(
        CASE
            WHEN label = 'SODIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS sodium,
    max(
        CASE
            WHEN label = 'TEMPERATURE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS temperature,
    max(
        CASE
            WHEN label = 'TIDALVOLUME'::text THEN valuenum
            ELSE NULL::double precision
        END) AS tidalvolume,
    max(
        CASE
            WHEN label = 'VENTILATIONRATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS ventilationrate,
    max(
        CASE
            WHEN label = 'VENTILATOR'::text THEN valuenum
            ELSE NULL::double precision
        END) AS ventilator
   FROM t2
  WHERE hr IS NOT NULL
  GROUP BY subject_id, hadm_id, icustay_id, hr
  ORDER BY subject_id, hadm_id, icustay_id, hr
WITH DATA;

-- mimiciii.labs_hourly_lm source

CREATE MATERIALIZED VIEW mimiciii.labs_hourly_lm
TABLESPACE pg_default
AS WITH t2 AS (
         WITH t1 AS (
                 SELECT ie.subject_id,
                    ie.hadm_id,
                    ie.icustay_id,
                        CASE
                            WHEN le.charttime >= mimiciii.datetime_sub(ie.intime, '06:00:00'::interval hour) AND le.charttime <= ie.intime THEN ie.intime
                            ELSE le.charttime
                        END AS charttime,
                        CASE
                            WHEN le.itemid = 50868 THEN 'ANION GAP'::text
                            WHEN le.itemid = 50862 THEN 'ALBUMIN'::text
                            WHEN le.itemid = 51144 THEN 'BANDS'::text
                            WHEN le.itemid = 50882 THEN 'BICARBONATE'::text
                            WHEN le.itemid = 50885 THEN 'BILIRUBIN'::text
                            WHEN le.itemid = 50912 THEN 'CREATININE'::text
                            WHEN le.itemid = 50806 THEN 'CHLORIDE'::text
                            WHEN le.itemid = 50902 THEN 'CHLORIDE'::text
                            WHEN le.itemid = 50809 THEN 'GLUCOSE'::text
                            WHEN le.itemid = 50931 THEN 'GLUCOSE'::text
                            WHEN le.itemid = 50810 THEN 'HEMATOCRIT'::text
                            WHEN le.itemid = 51221 THEN 'HEMATOCRIT'::text
                            WHEN le.itemid = 50811 THEN 'HEMOGLOBIN'::text
                            WHEN le.itemid = 51222 THEN 'HEMOGLOBIN'::text
                            WHEN le.itemid = 50813 THEN 'LACTATE'::text
                            WHEN le.itemid = 51265 THEN 'PLATELET'::text
                            WHEN le.itemid = 50822 THEN 'POTASSIUM'::text
                            WHEN le.itemid = 50971 THEN 'POTASSIUM'::text
                            WHEN le.itemid = 51275 THEN 'PTT'::text
                            WHEN le.itemid = 51237 THEN 'INR'::text
                            WHEN le.itemid = 51274 THEN 'PT'::text
                            WHEN le.itemid = 50824 THEN 'SODIUM'::text
                            WHEN le.itemid = 50983 THEN 'SODIUM'::text
                            WHEN le.itemid = 51006 THEN 'BUN'::text
                            WHEN le.itemid = 51300 THEN 'WBC'::text
                            WHEN le.itemid = 51301 THEN 'WBC'::text
                            ELSE NULL::text
                        END AS label,
                    le.valuenum
                   FROM mimiciii.icustays ie
                     LEFT JOIN mimiciii.labevents le ON le.subject_id = ie.subject_id AND le.hadm_id = ie.hadm_id AND le.charttime >= mimiciii.datetime_sub(ie.intime, '06:00:00'::interval hour) AND le.charttime <= ie.outtime AND le.valuenum IS NOT NULL AND le.valuenum > 0::double precision AND (le.itemid = ANY (ARRAY[50868, 50862, 51144, 50882, 50885, 50912, 50902, 50806, 50931, 50809, 51221, 50810, 51222, 50811, 50813, 51265, 50971, 50822, 51275, 51237, 51274, 50983, 50824, 51006, 51301, 51300]))
                )
         SELECT t1.subject_id,
            t1.hadm_id,
            ih.hr,
            t1.icustay_id,
            t1.label,
            t1.valuenum
           FROM t1
             LEFT JOIN mimiciii.icustay_hours ih ON t1.icustay_id = ih.icustay_id AND t1.charttime >= (ih.endtime - '01:00:00'::interval) AND t1.charttime < ih.endtime
        )
 SELECT subject_id,
    hadm_id,
    icustay_id,
    hr,
    min(
        CASE
            WHEN label = 'ANION GAP'::text THEN valuenum
            ELSE NULL::double precision
        END) AS aniongap_min,
    avg(
        CASE
            WHEN label = 'ANION GAP'::text THEN valuenum
            ELSE NULL::double precision
        END) AS aniongap_mean,
    max(
        CASE
            WHEN label = 'ANION GAP'::text THEN valuenum
            ELSE NULL::double precision
        END) AS aniongap_max,
    min(
        CASE
            WHEN label = 'ALBUMIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS albumin_min,
    avg(
        CASE
            WHEN label = 'ALBUMIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS albumin_mean,
    max(
        CASE
            WHEN label = 'ALBUMIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS albumin_max,
    min(
        CASE
            WHEN label = 'BANDS'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bands_min,
    avg(
        CASE
            WHEN label = 'BANDS'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bands_mean,
    max(
        CASE
            WHEN label = 'BANDS'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bands_max,
    min(
        CASE
            WHEN label = 'BICARBONATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bicarbonate_min,
    avg(
        CASE
            WHEN label = 'BICARBONATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bicarbonate_mean,
    max(
        CASE
            WHEN label = 'BICARBONATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bicarbonate_max,
    min(
        CASE
            WHEN label = 'BILIRUBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bilirubin_min,
    avg(
        CASE
            WHEN label = 'BILIRUBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bilirubin_mean,
    max(
        CASE
            WHEN label = 'BILIRUBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bilirubin_max,
    min(
        CASE
            WHEN label = 'CREATININE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS creatinine_min,
    avg(
        CASE
            WHEN label = 'CREATININE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS creatinine_mean,
    max(
        CASE
            WHEN label = 'CREATININE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS creatinine_max,
    min(
        CASE
            WHEN label = 'CHLORIDE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS chloride_min,
    avg(
        CASE
            WHEN label = 'CHLORIDE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS chloride_mean,
    max(
        CASE
            WHEN label = 'CHLORIDE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS chloride_max,
    min(
        CASE
            WHEN label = 'GLUCOSE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS glucose_min,
    avg(
        CASE
            WHEN label = 'GLUCOSE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS glucose_mean,
    max(
        CASE
            WHEN label = 'GLUCOSE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS glucose_max,
    min(
        CASE
            WHEN label = 'HEMATOCRIT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hematocrit_min,
    avg(
        CASE
            WHEN label = 'HEMATOCRIT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hematocrit_mean,
    max(
        CASE
            WHEN label = 'HEMATOCRIT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hematocrit_max,
    min(
        CASE
            WHEN label = 'HEMOGLOBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hemoglobin_min,
    avg(
        CASE
            WHEN label = 'HEMOGLOBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hemoglobin_mean,
    max(
        CASE
            WHEN label = 'HEMOGLOBIN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS hemoglobin_max,
    min(
        CASE
            WHEN label = 'LACTATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS lactate_min,
    avg(
        CASE
            WHEN label = 'LACTATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS lactate_mean,
    max(
        CASE
            WHEN label = 'LACTATE'::text THEN valuenum
            ELSE NULL::double precision
        END) AS lactate_max,
    min(
        CASE
            WHEN label = 'PLATELET'::text THEN valuenum
            ELSE NULL::double precision
        END) AS platelet_min,
    avg(
        CASE
            WHEN label = 'PLATELET'::text THEN valuenum
            ELSE NULL::double precision
        END) AS platelet_mean,
    max(
        CASE
            WHEN label = 'PLATELET'::text THEN valuenum
            ELSE NULL::double precision
        END) AS platelet_max,
    min(
        CASE
            WHEN label = 'POTASSIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS potassium_min,
    avg(
        CASE
            WHEN label = 'POTASSIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS potassium_mean,
    max(
        CASE
            WHEN label = 'POTASSIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS potassium_max,
    min(
        CASE
            WHEN label = 'PTT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS ptt_min,
    avg(
        CASE
            WHEN label = 'PTT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS ptt_mean,
    max(
        CASE
            WHEN label = 'PTT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS ptt_max,
    min(
        CASE
            WHEN label = 'INR'::text THEN valuenum
            ELSE NULL::double precision
        END) AS inr_min,
    avg(
        CASE
            WHEN label = 'INR'::text THEN valuenum
            ELSE NULL::double precision
        END) AS inr_mean,
    max(
        CASE
            WHEN label = 'INR'::text THEN valuenum
            ELSE NULL::double precision
        END) AS inr_max,
    min(
        CASE
            WHEN label = 'PT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS pt_min,
    avg(
        CASE
            WHEN label = 'PT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS pt_mean,
    max(
        CASE
            WHEN label = 'PT'::text THEN valuenum
            ELSE NULL::double precision
        END) AS pt_max,
    min(
        CASE
            WHEN label = 'SODIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS sodium_min,
    avg(
        CASE
            WHEN label = 'SODIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS sodium_mean,
    max(
        CASE
            WHEN label = 'SODIUM'::text THEN valuenum
            ELSE NULL::double precision
        END) AS sodium_max,
    min(
        CASE
            WHEN label = 'BUN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bun_min,
    avg(
        CASE
            WHEN label = 'BUN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bun_mean,
    max(
        CASE
            WHEN label = 'BUN'::text THEN valuenum
            ELSE NULL::double precision
        END) AS bun_max,
    min(
        CASE
            WHEN label = 'WBC'::text THEN valuenum
            ELSE NULL::double precision
        END) AS wbc_min,
    avg(
        CASE
            WHEN label = 'WBC'::text THEN valuenum
            ELSE NULL::double precision
        END) AS wbc_mean,
    max(
        CASE
            WHEN label = 'WBC'::text THEN valuenum
            ELSE NULL::double precision
        END) AS wbc_max
   FROM t2
  WHERE hr IS NOT NULL
  GROUP BY subject_id, hadm_id, icustay_id, hr
  ORDER BY subject_id, hadm_id, icustay_id, hr
WITH DATA;