.PHONY: pipeline get-data analytics help pipeline

VENV_DIR=.venv

help:
	@echo "Comandos disponíveis:"
	@echo " [rodar via bash] "
	@echo "  make get-data     - Executa o script de extração de dados (src/engineering/get_data.py)"
	@echo "  make analytics    - Executa o pipeline de analytics (src/analytics/pipeline_analytics.py)"
	@echo "  make pipeline     - Executa toda a pipeline (get-data + analytics)"
	@echo "  make predict      - Faz o predict de fiel a partir dos dados da tabela fs_all"

setup:
	bash -c "python -m venv .venv && source .venv/Scripts/activate && pip install -r requirements.txt"

get-data:
	bash -c "source .venv/Scripts/activate && cd src/engineering && python get_data.py"

analytics:
	bash -c "source .venv/Scripts/activate && cd src/analytics && python pipeline_analytics.py"

predict:
	bash -c "source .venv/Scripts/activate && cd src/analytics && python predict_fiel.py"

pipeline: get-data analytics predict
	@echo "Pipeline concluída e predict realizado com sucesso. Salvo na tabela fs_all no banco analitico"
