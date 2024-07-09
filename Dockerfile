FROM wolframresearch/wolframengine:13.3

USER root

RUN apt-get update && \
    apt-get install -y pciutils wget cmake git build-essential libncurses5-dev libncursesw5-dev libsystemd-dev libudev-dev libdrm-dev pkg-config

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /project

WORKDIR /project

RUN echo "if [ -z \"\$WOLFRAM_ID\" ] || [ -z \"\$WOLFRAM_PASSWORD\" ]; then echo 'Error: WOLFRAM_ID and WOLFRAM_PASSWORD credentials are required. Pass them in the .env file.'; exit 1; fi" > /usr/local/bin/check_credentials.sh && chmod +x /usr/local/bin/check_credentials.sh

RUN pip install jupyter
RUN pip install ipywidgets
RUN pip install jupyter_contrib_nbextensions
RUN pip install jupyterlab_execute_time
RUN pip install ipympl

COPY ./requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

EXPOSE 8888

RUN pip install metakernel

CMD /usr/local/bin/check_credentials.sh && \
    wolframscript -username $WOLFRAM_ID -password $WOLFRAM_PASSWORD && \
    sleep 2 && \
    # cd WolframLanguageForJupyter && wolframscript configure-jupyter.wls add && cd .. && \
    # ./WolframLanguageForJupyter/configure-jupyter.wls add && \
    jupyter lab --ip=* --port=8888 --allow-root --no-browser --notebook-dir=/project --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.default_url='/lab/tree'
