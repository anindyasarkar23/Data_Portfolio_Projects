SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION_DENSITY FROM COVID_DEATHS ORDER BY 1,2

--CASES VS DEATHS

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from COVID_DEATHS WHERE LOCATION LIKE '%INDIA%' AND continent IS NOT NULL
order by 1,2


--CASES VS POPULATION

Select location, date, total_cases, population,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS InfectedPercentage
from COVID_DEATHS WHERE LOCATION LIKE '%INDIA%' AND continent IS NOT NULL
order by 1,2


--LOOKING AT COUNTRIES HIGHEST INFECTION RATE COMPARED TO POPULATION

Select location, population, MAX(total_cases) AS HIGHEST_INFECTION_COUNT, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS InfectedPercentage
from COVID_DEATHS 
WHERE continent IS NOT NULL
GROUP BY location,population
order by InfectedPercentage DESC

--LOOKING AT CONTINENT HIGHEST INFECTION RATE COMPARED TO POPULATION

Select continent, MAX(CAST(total_deaths AS INT)) AS HIGHEST_DEATH_COUNT
from COVID_DEATHS 
WHERE continent IS NOT NULL
GROUP BY continent
order by HIGHEST_DEATH_COUNT DESC


--Global New case vs Global Deaths based on Dates 


Select date, sum(new_cases) as Global_Case_Count,sum(cast(new_deaths as int))as Global_Death_Count  
from COVID_DEATHS 
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2


--TOTAL POPULATION VS VACCINATION 

--CTE

WITH POPVSVAC (CONTINENT,LOCATION,DATE,POPULATION,NEW_VACCINATIONS,ROLLING_POPULATION_VACCINATED)
AS
(
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS ROLLING_POPULATION_VACCINATED
FROM COVID_DEATHS DEA JOIN 
COVID_VACCINATIONS VAC ON VAC.location=DEA.location AND VAC.DATE=DEA.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 1,2,3
)

SELECT *,(ROLLING_POPULATION_VACCINATED/POPULATION)*100 AS ROLLING_PERCENTAGE
FROM POPVSVAC


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS ROLLING_POPULATION_VACCINATED
FROM COVID_DEATHS DEA JOIN 
COVID_VACCINATIONS VAC ON VAC.location=DEA.location AND VAC.DATE=DEA.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *,(Rolling_People_Vaccinated/POPULATION)*100 AS ROLLING_PERCENTAGE
FROM #PercentPopulationVaccinated


--CREATING VIEWS ON THE ABOVE CONDITION FOR PERCENTAGE_POPULATION_VACCINATED

CREATE VIEW PercentPopulationVaccinated AS 
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS ROLLING_POPULATION_VACCINATED
FROM COVID_DEATHS DEA JOIN 
COVID_VACCINATIONS VAC ON VAC.location=DEA.location AND VAC.DATE=DEA.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 1,2,3