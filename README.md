# 📊 Quarterly Customer Growth & Activation Analysis (SQL)

## 📌 Objective

This project analyzes the quarterly evolution of customer acquisition and activation over the last two years.

The goal is to evaluate growth trends and measure the effectiveness of activation strategies.

---

## 🛠 Tools & Technologies

* SQL (PostgreSQL)
* Data Analysis

---

## 📊 Business Problem

Understanding how customer acquisition and activation evolve over time is critical for strategic decision-making.

This analysis answers:

* How many customers are acquired each quarter?
* How many become active (make their first purchase)?
* What is the activation rate?
* Is the business growing over time?

---

## 🧮 SQL Analysis

```sql
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
```

---

## 📈 Metrics

* Accounts created per quarter
* Accounts activated (first purchase)
* Activation rate (%)
* Growth rate (%)

---

## 🧠 Key Insights

* Activation rate measures how effective onboarding strategies are
* Growth rate reveals business expansion trends
* Seasonal patterns may indicate market behavior changes
* Low activation may indicate issues in conversion funnel

---

## 🚀 Conclusion

This analysis provides a strategic view of customer lifecycle performance, helping businesses optimize acquisition and activation strategies.

---

## 👨‍💻 Author

Manoel Sousa Gomes

🔗 LinkedIn: https://www.linkedin.com/in/manoel-sousa-712a6b240/
🔗 GitHub: https://github.com/Maelsousa

