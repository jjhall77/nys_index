# NYS Penal Law CHI Lookup Table - AUDIT DOCUMENT

## Purpose
Cross-reference each `law_code_trim` against actual NYS Penal Law to verify correct classification and CHI weight.

---

## Sentencing Reference (PL 70.02)

| Class | Violent Range (Determinate) | Non-Violent Range | CHI Midpoint |
|-------|----------------------------|-------------------|--------------|
| A-I | 15-40 yrs to life | N/A | 5,475-7,300 |
| B Violent | 5-25 years | N/A | **5,475** |
| B Non-Violent | N/A | 1-3 to 8⅓-25 years | 1,825 |
| C Violent | 3.5-15 years | N/A | **3,380** |
| C Non-Violent | N/A | 1-2 to 5-15 years | 1,095 |
| D Violent | 2-7 years | N/A | **1,643** |
| D Non-Violent | N/A | 0 to 2⅓-7 years | 730 |
| E Violent | 1.5-4 years | N/A | **1,004** |
| E Non-Violent | N/A | 0 to 1⅓-4 years | 365 |
| A Misd | N/A | 0-1 year | 183 |

---

## PL 70.02(1) Violent Felony Enumeration

### Class B Violent Felonies (CHI = 5,475)
- **120.07** Gang Assault 1st
- **120.10** Assault 1st  
- **120.11** Aggravated Assault on Police/Peace Officer
- 125.20 Manslaughter 1st
- 140.30 Burglary 1st
- **160.15** Robbery 1st

### Class C Violent Felonies (CHI = 3,380)
- **120.06** Gang Assault 2nd
- **120.08** Assault on Police/Fire/EMS
- 120.09 Assault on a Judge
- **121.13** Strangulation 1st ⚠️
- 140.25 Burglary 2nd
- **160.10** Robbery 2nd
- 265.03 CPW 2nd

### Class D Violent Felonies (CHI = 1,643)
- 120.02 Reckless Assault of Child
- **120.05** Assault 2nd
- **120.18** Menacing Police/Peace Officer
- 120.60(1) Stalking 1st
- **121.12** Strangulation 2nd ⚠️
- **160.05** Robbery 3rd

---

## AUDIT TABLE

### Article 125 - Homicide

| Code | Current Name | Current Class | Current CHI | **Verified Name** | **Verified Class** | **Verified CHI** | Status |
|------|--------------|---------------|-------------|-------------------|-------------------|------------------|--------|
| PL 12527 | Murder 1st | A-I | 7,300 | Murder 1st | A-I | 7,300 | ✅ |
| PL 12525 | Murder 2nd | A-I | 5,475 | Murder 2nd | A-I | 5,475 | ✅ |
| PL 12520 | Manslaughter 1st | B | 5,475 | Manslaughter 1st | B Violent | 5,475 | ✅ |
| PL 12515 | Manslaughter 2nd | C | 1,643 | Manslaughter 2nd | C Non-V | 1,095 | ⚠️ |

**Note on 125.15:** Manslaughter 2nd is NOT enumerated in 70.02 as violent. As a C non-violent, should be 1,095 not 1,643.

---

### Article 120 - Assault

| Code | Current Name | Current Class | Current CHI | **Verified Name** | **Verified Class** | **Verified CHI** | Status |
|------|--------------|---------------|-------------|-------------------|-------------------|------------------|--------|
| PL 12000 | Assault 3rd | A Misd | 183 | Assault 3rd | A Misd | 183 | ✅ |
| PL 12005 | Assault 2nd | D | 1,643 | Assault 2nd | D Violent | 1,643 | ✅ |
| PL 12006 | Gang Assault 2nd | C | 3,380 | Gang Assault 2nd | C Violent | 3,380 | ✅ |
| PL 12007 | Gang Assault 1st | B | 5,475 | Gang Assault 1st | B Violent | 5,475 | ✅ Fixed |
| PL 12008 | Assault on Police/Fire/EMS | C | 3,380 | Assault on Police/Fire/EMS | C Violent | 3,380 | ✅ Fixed |
| PL 12010 | Assault 1st | B | 5,475 | Assault 1st | B Violent | 5,475 | ✅ |
| PL 12011 | Agg Assault on Police | B | 7,300 | Agg Assault on Police | B Violent | **5,475** | ❌ |
| PL 12014 | Menacing Police | D | 1,643 | *See 120.18* | - | - | ⚠️ |
| PL 12016 | Hazing 1st | A Misd | 183 | Hazing 1st | A Misd | 183 | ✅ |
| PL 12045 | Stalking 2nd | E | 730 | Stalking 2nd | E Non-V | 365 | ⚠️ |
| PL 12055 | "Assault 2nd" | D | 1,643 | **Stalking 2nd** | E Non-V | **730** | ❌ |
| PL 12060 | "Assault 2nd" | D | 1,643 | **Stalking 1st** | D Violent | 1,643 | ⚠️ Name |

**Critical errors found:**
1. **PL 12011**: Listed as 7,300 days but B Violent max midpoint is 5,475
2. **PL 12055**: This is 120.55 = Stalking 2nd, NOT Assault 2nd
3. **PL 12060**: This is 120.60 = Stalking 1st, NOT Assault 2nd
4. **PL 12014**: Section 120.14 is Menacing 2nd (A Misd). Menacing Police is 120.18

---

### Article 121 - Strangulation

| Code | Current Name | Current Class | Current CHI | **Verified Name** | **Verified Class** | **Verified CHI** | Status |
|------|--------------|---------------|-------------|-------------------|-------------------|------------------|--------|
| PL 12111 | Crim Obstr Breathing | A Misd | 183 | Crim Obstr Breathing | A Misd | 183 | ✅ |
| PL 12112 | "Strangulation 1st" | C | 3,380 | **Strangulation 2nd** | D Violent | **1,643** | ❌❌ |
| PL 12113 | "Strangulation 2nd" | D | 1,643 | **Strangulation 1st** | C Violent | **3,380** | ❌❌ |

**CRITICAL ERROR:** The strangulation codes are SWAPPED!
- 121.12 = Strangulation **2nd** (D Violent, 1,643)
- 121.13 = Strangulation **1st** (C Violent, 3,380)

---

### Article 160 - Robbery

| Code | Current Name | Current Class | Current CHI | **Verified Name** | **Verified Class** | **Verified CHI** | Status |
|------|--------------|---------------|-------------|-------------------|-------------------|------------------|--------|
| PL 16005 | Robbery 3rd | D | 1,643 | Robbery 3rd | D Violent | 1,643 | ✅ |
| PL 16010 | Robbery 2nd | C | 3,380 | Robbery 2nd | C Violent | 3,380 | ✅ |
| PL 16015 | Robbery 1st | B | 5,475 | Robbery 1st | B Violent | 5,475 | ✅ |

---

### Article 140 - Burglary

| Code | Current Name | Current Class | Current CHI | **Verified Name** | **Verified Class** | **Verified CHI** | Status |
|------|--------------|---------------|-------------|-------------------|-------------------|------------------|--------|
| PL 14020 | Burglary 3rd | D Non-V | 1,278 | Burglary 3rd | D Non-V | **730** | ⚠️ |
| PL 14025 | Burglary 2nd | C | 3,380 | Burglary 2nd | C Violent | 3,380 | ✅ |
| PL 14030 | Burglary 1st | B | 5,475 | Burglary 1st | B Violent | 5,475 | ✅ |

**Note:** Burglary 3rd (140.20) is NOT in the 70.02 violent felony list. Current CHI of 1,278 seems arbitrary—D non-violent midpoint would be 730.

---

### Article 155 - Larceny (all non-violent)

| Code | Current Name | Current Class | Current CHI | Status |
|------|--------------|---------------|-------------|--------|
| PL 15530 | Grand Larceny 4th | E Non-V | 365 | ✅ |
| PL 15535 | Grand Larceny 3rd | D Non-V | 730 | ✅ |
| PL 15540 | Grand Larceny 2nd | C Non-V | 1,095 | ✅ |
| PL 15542 | Grand Larceny 1st | B Non-V | 1,825 | ✅ |

---

## Summary of Errors

### Critical (Wrong CHI by 1,000+ days)
| Code | Error | Current CHI | Correct CHI | Impact |
|------|-------|-------------|-------------|--------|
| PL 12112 | Strang 2nd labeled as 1st | 3,380 | **1,643** | -1,737 |
| PL 12113 | Strang 1st labeled as 2nd | 1,643 | **3,380** | +1,737 |
| PL 12011 | B Violent over-weighted | 7,300 | **5,475** | -1,825 |
| PL 12055 | Wrong offense entirely | 1,643 | **730** | -913 |

### Moderate (Wrong but <1,000 days)
| Code | Error | Current CHI | Correct CHI | Impact |
|------|-------|-------------|-------------|--------|
| PL 12515 | Mansl 2nd as violent | 1,643 | 1,095 | -548 |
| PL 12045 | Stalking 2nd violent status | 730 | 365? | -365 |
| PL 14020 | Burglary 3rd arbitrary | 1,278 | 730 | -548 |

### Naming Only (Correct CHI)
- PL 12007: Was "Assault on Police" → Gang Assault 1st ✅ Fixed
- PL 12008: Was "Assault on child" → Assault on Police/Fire/EMS ✅ Fixed
- PL 12060: Is Stalking 1st, not Assault 2nd (but CHI happens to be same)

---

## Questions for Your Review

1. **Strangulation swap**: This is the biggest error. Do you have many 12112/12113 codes in the arrest data?

2. **120.18 vs 120.14**: The current lookup has "PL 12014" for Menacing Police, but actual section is 120.18. Is "PL 12014" appearing in your data, and if so, what does NYPD mean by it?

3. **Non-violent felony weights**: Should we use the full midpoint (e.g., 730 for D non-violent) or something else? The current table uses inconsistent values.

4. **120.55 and 120.60**: Are these (Stalking 2nd/1st) appearing in Felony Assault complaints? If so, they may be errant charges that should be filtered out.

---

## IMPORTANT: Article 125 Attempts Under Felony Assault

**Key finding from user:** Article 125 (Murder/Manslaughter) charges that appear under `offense_description1 = "FELONY ASSAULT"` are **ATTEMPTS**, not completed offenses.

This means:
- PL 125.25 (Murder 2nd) under Felony Assault → **Attempted Murder 2nd** (B Violent attempt)
- PL 125.20 (Manslaughter 1st) under Felony Assault → **Attempted Manslaughter 1st** (C Violent attempt)

**CHI adjustment:**
| Charge | Under Murder Category | Under Felony Assault | Attempt CHI |
|--------|----------------------|---------------------|-------------|
| 125.27 Murder 1st | 7,300 (completed) | **5,475** (B attempt) | -1,825 |
| 125.25 Murder 2nd | 5,475 (completed) | **5,475** (B attempt) | 0 |
| 125.20 Mansl 1st | 5,475 (completed) | **3,380** (C attempt) | -2,095 |
| 125.15 Mansl 2nd | 1,095 (completed) | **730** (D attempt) | -365 |

**Code fix:** Added logic to treat Article 125 codes under Felony Assault as attempts:
```r
is_attempt = (arrest_charge_attempt_flag == "Y") | 
             (offense_description1 == "FELONY ASSAULT" & str_detect(law_code, "^PL 125"))
```
