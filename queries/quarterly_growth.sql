-- 📊 Quarterly Customer Growth & Activation Analysis
-- Objective: Analyze quarterly trends of customer acquisition and activation

WITH first_purchase AS (
    SELECT 
        id_cliente,
        MIN(dt_venda) AS first_purchase_date
    FROM decisionscard.t_venda
    WHERE fl_status_venda = 'A'
    GROUP BY id_cliente
),

accounts_by_period AS (
    SELECT 
        EXTRACT(YEAR FROM tc.dt_cadastro) AS year,
        EXTRACT(QUARTER FROM tc.dt_cadastro) AS quarter,
        TO_CHAR(tc.dt_cadastro, 'YYYY') || '-T' || EXTRACT(QUARTER FROM tc.dt_cadastro) AS period,
        
        COUNT(tc.id_cliente) AS accounts_created,

        COUNT(fp.id_cliente) FILTER (
            WHERE DATE_TRUNC('quarter', fp.first_purchase_date) = DATE_TRUNC('quarter', tc.dt_cadastro)
        ) AS accounts_activated

    FROM decisionscard.t_cliente tc
    LEFT JOIN first_purchase fp 
        ON tc.id_cliente = fp.id_cliente

    WHERE tc.dt_cadastro >= (
        SELECT MAX(dt_cadastro) - INTERVAL '2 years'
        FROM decisionscard.t_cliente
    )

    GROUP BY year, quarter, period
)

SELECT
    year,
    quarter,
    period,
    accounts_created,
    accounts_activated,

    ROUND(
        (accounts_activated::NUMERIC / NULLIF(accounts_created, 0)) * 100,
        2
    ) AS activation_rate,

    ROUND(
        (
            (accounts_created - LAG(accounts_created) OVER (ORDER BY year, quarter))::NUMERIC
            / NULLIF(LAG(accounts_created) OVER (ORDER BY year, quarter), 0)
        ) * 100,
        2
    ) AS growth_rate

FROM accounts_by_period
ORDER BY year, quarter;
