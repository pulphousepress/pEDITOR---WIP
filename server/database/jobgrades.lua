-- server/database/jobgrades.lua
-- theme="1950s-cartoon-noir"
-- Job grade helpers (uses la_peditor.Database)

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.JobGrades = Database.JobGrades or {}

function Database.JobGrades.Get(jobName, grade)
    return Database.Fetch([[
        SELECT * FROM job_grades
        WHERE job_name = ? AND grade = ?
    ]], { jobName, grade })
end

function Database.JobGrades.GetAllByJob(jobName)
    return Database.FetchAll([[
        SELECT * FROM job_grades
        WHERE job_name = ?
        ORDER BY grade ASC
    ]], { jobName })
end

return Database.JobGrades
