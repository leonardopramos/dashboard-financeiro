/*
    Script para cadastrar metas financeiras e contribuições históricas
    para o usuário de demonstração.

    Pré-requisitos:
      - Contas, categorias e transações já inseridas.
      - Ajuste os identificadores somente se estiver reaproveitando para outro usuário.

    Execução sugerida:
        mysql -u root -p < backend/dashboard-financeiro/scripts/user_demo_goals_seed.sql
*/

USE dashboard_financeiro;

SET @UserId = UUID_TO_BIN('9d329bc3-24ac-4cfa-81b0-1de71f4afa63');

SET @CategoryTravelId        = UUID_TO_BIN('c1176066-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryEducationId     = UUID_TO_BIN('c22a1210-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryLeisureId       = UUID_TO_BIN('c08f7437-c0bd-11f0-9c2d-a2aaf7edcf84');

SET @Now = UTC_TIMESTAMP(6);
SET @MonthStart = DATE_SUB(DATE(@Now), INTERVAL (DAY(@Now) - 1) DAY);
SET @MonthsBack = 11; -- 12 meses de histórico

/*
    Descomente os blocos abaixo se precisar reaplicar o seed.
*/
-- DELETE gc
-- FROM goal_contributions gc
-- INNER JOIN financial_goals fg ON fg.id = gc.goal_id
-- WHERE fg.user_id = @UserId;
--
-- DELETE FROM financial_goals
-- WHERE user_id = @UserId;

START TRANSACTION;

    SET @GoalEmergencyId    = UUID_TO_BIN(UUID());
    SET @GoalTripId         = UUID_TO_BIN(UUID());
    SET @GoalEducationId    = UUID_TO_BIN(UUID());
    SET @GoalLeisureLimitId = UUID_TO_BIN(UUID());

    INSERT INTO financial_goals (
        id,
        user_id,
        name,
        goal_type,
        category_id,
        target_amount,
        current_amount,
        start_date,
        end_date,
        goal_status,
        description,
        active,
        notify_on_achieve,
        notify_on_exceed,
        achieved_at,
        created_at,
        updated_at
    )
    VALUES
        (@GoalEmergencyId, @UserId, 'Reserva de emergência 6 meses', 'SAVINGS', NULL,
         45000.00, 31200.00,
         DATE_ADD(@MonthStart, INTERVAL -24 MONTH), DATE_ADD(@MonthStart, INTERVAL 6 MONTH),
         'IN_PROGRESS', 'Fundo para cobrir seis meses de despesas fixas e saúde.',
         1, 1, 1, NULL,
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -24 MONTH), @Now),
        (@GoalTripId, @UserId, 'Viagem internacional anual', 'SAVINGS', @CategoryTravelId,
         16000.00, 16450.00,
         DATE_ADD(@MonthStart, INTERVAL -12 MONTH), DATE_ADD(@MonthStart, INTERVAL 1 MONTH),
         'ACHIEVED', 'Experiência cultural com a família no exterior.',
         1, 1, 1, DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -1 MONTH),
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -12 MONTH), @Now),
        (@GoalEducationId, @UserId, 'Fundo MBA e certificações', 'SAVINGS', @CategoryEducationId,
         13000.00, 9200.00,
         DATE_ADD(@MonthStart, INTERVAL -18 MONTH), DATE_ADD(@MonthStart, INTERVAL 10 MONTH),
         'IN_PROGRESS', 'Reserva para cursos executivos e certificações de tecnologia.',
         1, 1, 1, NULL,
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -18 MONTH), @Now),
        (@GoalLeisureLimitId, @UserId, 'Controle de gastos com lazer', 'EXPENSE_LIMIT', @CategoryLeisureId,
         1200.00, 1340.00,
         DATE_ADD(@MonthStart, INTERVAL -5 MONTH), DATE_ADD(@MonthStart, INTERVAL 2 MONTH),
         'EXCEEDED', 'Limite mensal para manter lazer equilibrado.',
         1, 0, 1, NULL,
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -5 MONTH), @Now);

    -- Contribuições mensais das metas de poupança
    INSERT INTO goal_contributions (
        id,
        goal_id,
        user_id,
        amount,
        description,
        allocation_date,
        created_at,
        updated_at
    )
    SELECT
        UUID_TO_BIN(UUID()),
        template.goal_id,
        @UserId,
        ROUND(
            GREATEST(
                template.min_amount,
                template.base_amount + (mw.idx * template.monthly_delta) +
                (CASE
                    WHEN template.seasonal_period > 0 AND MOD(mw.idx, template.seasonal_period) = 0
                    THEN template.seasonal_boost
                    ELSE 0
                END)
            ),
            2
        ) AS amount,
        template.description,
        DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS allocation_date,
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 18 HOUR
        ),
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 18 HOUR
        )
    FROM (
        SELECT 0 AS idx UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
        SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    ) AS mw
    JOIN (
        SELECT @GoalEmergencyId AS goal_id, 'Aporte reserva emergência' AS description,
               26 AS day_offset, 980.00 AS base_amount, -14.00 AS monthly_delta,
               0 AS seasonal_period, 0.00 AS seasonal_boost, 780.00 AS min_amount,
               @MonthsBack AS max_month_offset
        UNION ALL
        SELECT @GoalTripId, 'Poupança viagem anual',
               9, 820.00, -26.00, 4, 320.00, 620.00, 8
        UNION ALL
        SELECT @GoalEducationId, 'Fundo educação e cursos',
               17, 540.00, -5.00, 3, 160.00, 380.00, @MonthsBack
    ) AS template (
        goal_id,
        description,
        day_offset,
        base_amount,
        monthly_delta,
        seasonal_period,
        seasonal_boost,
        min_amount,
        max_month_offset
    )
    WHERE mw.idx <= template.max_month_offset;

    -- Contribuições pontuais relevantes
    INSERT INTO goal_contributions (
        id,
        goal_id,
        user_id,
        amount,
        description,
        allocation_date,
        created_at,
        updated_at
    )
    VALUES
        (UUID_TO_BIN(UUID()), @GoalTripId,      @UserId, 2500.00, 'Bônus convertido em viagem',   DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 5 DAY),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 5 DAY) AS DATETIME),  INTERVAL 18 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 5 DAY) AS DATETIME),  INTERVAL 18 HOUR)),
        (UUID_TO_BIN(UUID()), @GoalEducationId, @UserId, 1800.00, 'Reembolso empresa direcionado',DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH), INTERVAL 12 DAY), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 18 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 18 HOUR)),
        (UUID_TO_BIN(UUID()), @GoalEmergencyId, @UserId, 3200.00, '13º integral para reserva',    DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 3 DAY),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 3 DAY) AS DATETIME),  INTERVAL 18 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 3 DAY) AS DATETIME),  INTERVAL 18 HOUR));

COMMIT;

-- Relatório rápido das metas inseridas
SELECT
    fg.name,
    fg.goal_type,
    fg.target_amount,
    fg.current_amount,
    fg.goal_status,
    fg.start_date,
    fg.end_date,
    COUNT(gc.id) AS total_contributions,
    SUM(gc.amount) AS aportes_registrados
FROM financial_goals fg
LEFT JOIN goal_contributions gc ON gc.goal_id = fg.id
WHERE fg.user_id = @UserId
GROUP BY fg.id;
