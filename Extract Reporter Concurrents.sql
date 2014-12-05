-- STAGE: LAX-SQL-101S.PROD.LOCAL\SPSS
-- PROD: LAX-SPSS-101P.PROD.LOCAL\SPSS

--SELECT TOP 100 * FROM mrUserData.dbo.ApplicationSessionHistory
--SELECT TOP 100 * FROM mrUserData.dbo.Users
--SELECT TOP 100 * FROM mrUserData.dbo.UserSessionHistory

--SELECT MIN(ApplicationSessionStart), MAX(ApplicationSessionStart) FROM mrUserData.dbo.ApplicationSessionHistory
--SELECT DISTINCT ApplicationId FROM mrUserData.dbo.ApplicationSessionHistory ORDER BY 1

SELECT a.ApplicationId, COUNT(1)
	--u.[Description], a.UserName, a.ApplicationId, a.ProjectId, a.ApplicationSessionStart, a.ApplicationSessionEnd,
	--DATEDIFF(second, a.ApplicationSessionStart, a.ApplicationSessionEnd) AS DurationInSeconds
FROM
	mrUserData.dbo.ApplicationSessionHistory (NOLOCK) a
	INNER JOIN mrUserData.dbo.Users (NOLOCK) u ON a.UserName = u.UserName
WHERE
	a.ApplicationId = 'Reporter' -- IN ('ActivateReporter','Reporter')
	AND a.ApplicationSessionStart >  DATEADD(yy, -1, GETDATE())
GROUP BY a.ApplicationId