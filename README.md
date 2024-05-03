# Do electrical interties stimulate Canadian hydroelectric development? Using causal inference to identify second-order impacts in evolving sociotechnical systems
<img alt="GitHub Release Date - Published_At" src="https://img.shields.io/github/release-date/amirgazar/Environmental-Impact-Assessment?color=black"> <img alt="GitHub last commit (by committer)" src="https://img.shields.io/github/last-commit/amirgazar/Environmental-Impact-Assessment?color=gold"> <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/amirgazar/Environmental-Impact-Assessment?color=cyan"> [<img alt="Static Badge" src="https://img.shields.io/badge/license-CC--BY--4.0-tst">](https://creativecommons.org/licenses/by/4.0/) [<img alt="Static Badge" src="https://img.shields.io/badge/preprint-doi.org/10.31224/3358-blue">](https://doi.org/10.31224/3358)

<div data-target="readme-toc.content" class="Box-body px-5 pb-5">

<div class="topper-featured-image__inner">
    <figure class="topper-featured-image__figure">
        <img src="https://github.com/amirgazar/Environmental-Impact-Assessment/blob/main/misc/Transmission_line.jpg" alt="">
        <figcaption class="topper-featured-image__caption topper-featured-image__caption--">
            Image courtsey of American Public Power Association
        </figcaption>
    </figure>
</div>

<h2 tabindex="-1" id="user-content-contents" dir="auto">Abstract<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"></svg></a></h2>
Debates over the scope of environmental impact, life-cycle, and cost-benefit analysis frequently revolve around disagreements on the causal structure of complex sociotechnical systems. Environmental advocates in the United States have claimed that new electrical interties with Canada increase development of Canadian hydroelectric resources, leading to environmental and health impacts associated with new reservoirs. Assertions of such second-order impacts of two recently proposed 9.5 TWh year<sup>-1</sup> transborder transmission projects played a role in their suspension. We demonstrate via Bayesian network modeling that development of Canadian hydroelectric resources is stimulated by price signals and domestic demand rather than increased export capacity per se. However, hydropower exports are increasingly arranged via long-term power purchase agreements that may promote new generation in a way that is not easily modeled with publicly available data. Overall, this work suggests lesser consideration of generation-side impacts in permitting transborder transmission infrastructure while highlighting the need for higher resolution data to model the Quebec-New England-New York energy system at the project scale. More broadly, Bayesian analysis can be used to elucidate causal drivers in evolving sociotechnical systems to develop consensus for the scope of impacts to consider in environmental impact, life cycle, and cost-benefit analysis. 

<h2 tabindex="-1" id="user-content-contents" dir="auto">Contents<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h2>

<ul dir="auto">
<li><a href="#overview">Overview</a></li>
<li><a href="#repo-contents">Repo Contents</a></li>
<li><a href="#system-requirements">System Requirements</a></li>
<li><a href="#installation-guide">Installation Guide</a></li>
<li><a href="#Developed-New-Functions">Developed New Functions</a></li>
<li><a href="#citations">Citation.bib</a></li>
<li><a href="#Copyrights">Copyrights</a></li>
</ul>
<h1 tabindex="-1" id="user-content-overview" dir="auto">Overview<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h1>
<p dir="auto"> This repository contains data, instructions, and code for the "Do electrical interties stimulate Canadian hydroelectric development? Using causal inference to scope environmental impact assessment in evolving sociotechnical systems" paper. This repository includes R code, a manual for using the code and utilizing the <code>bnlearn</code><sup>[1]</sup> package in this context, and a real dataset for practical application.

<h1 tabindex="-1" id="user-content-repo-contents" dir="auto">Repo Contents<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h1>
<ul dir="auto">
<li>
  <a href="R files">R files</a>: contains <code>R</code> files
</li>

<li><a href="doc/Reproduction Information.pdf">doc</a>: code reproduction information, manual for using the <code>bnlearn</code> package on our dataset</li>
<li><a href="data">data</a>: real dataset to use in the <code>R</code> session</li>
<li><a href="citation.bib">citation</a>: bib code to use when citing this code or the manuscript</li>
<li><a href="LICENSE">license</a>: creative commons attribution 4.0 international license</li>
<li><a href="misc">misc</a>: includes miscellaneous files such as source code to generate Figure 4 in the manuscript </li>
</ul>
<h1 tabindex="-1" id="user-content-system-requirements" dir="auto">System Requirements<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h1>
<h2 tabindex="-1" id="user-content-hardware-requirements" dir="auto">Hardware and OS Requirements<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h2>
<p dir="auto">We utilized a MacBook Pro with an Apple M1 Pro chip, featuring an 8-core CPU and 16 GB of memory. The startup disk is the Macintosh HD. The system operates on <code>macOS 13.2.1 (22D68) Ventura</code>.</p>

<h2 tabindex="-1" id="user-content-software-requirements" dir="auto">Software Requirements<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h2>

<p dir="auto">This code is tested on <em>macOS</em> operating systems. The Comprehensive R Archive Network (CRAN) package which is the underlying softawre for this code, is compatible with Windows, Mac, and Linux operating systems.</p>
<p dir="auto">Before setting up the <code>R</code> code, users should have <code>R</code> version 4.3.1 (2023-06-16) Beagle Scouts or higher, and several packages set up from CRAN.</p>


<h1 tabindex="-1" id="user-content-installation-guide" dir="auto">Installation Guide<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h1>
<h2 tabindex="-1" id="user-content-stable-release" dir="auto">Install R and R-Studio<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h2>

<p dir="auto">You can download and install <code>R</code> via <code>CRAN</code> for free from this <a href="https://cran.r-project.org/bin/macosx/" target="_blank">link</a>.
You can download and install <code>R Studio</code> for free from this <a href="https://posit.co/download/rstudio-desktop/" target="_blank">link</a>.</p>
<h2 tabindex="-1" id="user-content-development-version" dir="auto">Install Packages<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h2>

<p dir="auto">Users should install the following packages prior to running the supplied <code>R</code> code, from an <code>R</code> terminal:</p>
<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>install.packages(c("bnlearn", "gRain", "visNetwork", "ggplot2", 
              "zoo", "scales", "gridExtra", "dplyr", "MASS", "svglite", "tidyverse"))
</code></pre><div class="zeroclipboard-container position-absolute right-0 top-0">
    <clipboard-copy aria-label="Copy" class="ClipboardButton btn js-clipboard-copy m-2 p-0 tooltipped-no-delay" data-copy-feedback="Copied!" data-tooltip-direction="w" value="install.packages(c('ggplot2', 'abind', 'irlba', 'knitr', 'rmarkdown', 'latex2exp', 'MASS', 'randomForest'))" tabindex="0" role="button">
      <svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-copy js-clipboard-copy-icon m-2">
    <path d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 0 1 0 1.5h-1.5a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-1.5a.75.75 0 0 1 1.5 0v1.5A1.75 1.75 0 0 1 9.25 16h-7.5A1.75 1.75 0 0 1 0 14.25Z"></path><path d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0 1 14.25 11h-7.5A1.75 1.75 0 0 1 5 9.25Zm1.75-.25a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-7.5a.25.25 0 0 0-.25-.25Z"></path>
</svg>
      <svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true" class="octicon octicon-check js-clipboard-check-icon color-fg-success d-none m-2">
    <path d="M13.78 4.22a.75.75 0 0 1 0 1.06l-7.25 7.25a.75.75 0 0 1-1.06 0L2.22 9.28a.751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018L6 10.94l6.72-6.72a.75.75 0 0 1 1.06 0Z"></path>
</svg>
    </clipboard-copy>
  </div></div>
<p dir="auto">which will install in about a few minutes on a machine with similar specs.</p>
<p dir="auto">All packages in their latest versions as they appear on <code>CRAN</code> on November 10, 2013. The versions of packages are:</p>
<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>Rgraphviz 2.44.0
bnlearn 4.8.3
gRain 1.3.13
visNetwork 2.1.2
ggplot2 3.4.2
zoo 1.8.12
scales 1.2.1
gridExtra 2.3
dplyr 1.1.2
MASS 7.3.60
svglite 2.1.1
tidyverse 2.0.0
</code></pre>

<h2 tabindex="-1" id="user-content-package-installation" dir="auto">Code Runtime<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h2>
<p dir="auto">The runtime on our operating system for this code in <code>R</code> is approximately 15 seconds.</p>

<h1 tabindex="-1" id="user-content-demo" dir="auto">Developed New Functions<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h1>
<p dir="auto">We have developed the following functions to simplify the algorithm: </p>

<h2 id="D-separation">D-Separation Function</h2>
<p dir="auto">We have created the <code>dsep.dag</code> function that can evaluate d-separation for any given node pair.  This function uses the optimized DAG results to identify the following for each node pair and then calculates conditional independence: 1. Parents; 2. Neighbors (i.e., parents and children for each node); and 3. Markov-Blanket (i.e., parents, children, and parents of children for each node). Furthermore, this function uses data to evaluate d-separation in addition to the results of DAG discovery. This combines the functionalities of the <code>ci.test</code> and <code>dsep</code> functions available in the <code>bnlearn</code> package. Where <code>ci.test</code> exclusively utilizes data, while <code>dsep.dag</code> solely employs DAGs.</p>
<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>dsep.dag(x, data, z)</span>
</code></pre>

<h4>Parameters</h4>
<p>The <code>dsep.dag</code> function accepts the following parameters:</p>
<ul>
  <li><code>x</code>: an object of class <code>bn</code></li>
  <li><code>data</code>: a data frame containing the variables in the model</li>
  <li><code>z</code>: a list, where each element is a character vector representing a pair of node labels</li>
  <!-- The following item is commented out, as in the original LaTeX source -->
  <!-- <li><strong>set</strong>: a character string, the label of the conditioning set to be used in the algorithm. If none is specified, three default sets are used</li> -->
</ul>

<h2 id="DAG Visualizer">DAG Visualizer</h2>
<p>The <code>plot.network</code> function visualizes and returns DAGs returned by the <code>bnlearn</code> package.</p>

<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>plot.network(structure, ht = "400px", title)
</code></pre>

<h4>Parameters</h4>
<p>The <code>plot.network</code> function accepts the following parameters:</p>
<ul>
  <li><code>structure</code>: an object of class <code>bn</code></li>
  <li><code>ht</code>: a string specifying the height of the plot. If none is specified, the default value will be 400px</li>
  <li><code>title</code>: a character string, the title of the plot. If none is specified, the title will be blank</li>

</ul>

<h2 id="Box-Cox Transformer">Box-Cox Transformer</h2>
<p>The <code>transform_and_test</code> function evaluates the data set, checks for normality (using the Shapiro-Wilk test), and transforms the non-Gaussian variables using the Box-Cox transformation. Re-evaluates the transformed variables with the Shapiro-Wilk test and checks for normality. Returns the results.</p>
<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>transform_and_test(data, z)</span>
</code></pre>

<h4>Parameters</h4>
<p>The <code>transform_and_test</code> function accepts the following parameters:</p>
<ul>
  <li><code>data</code>: a data frame containing the variables in the model</li>
  <li><code>z</code>: a list, where each element is a character vector representing a variable</li>
</ul>

<h2 id="Fitness Test">Goodness of Fit Test</h2>
<p>The <code>evaluate_fit_continuous</code> and <code>evaluate_fit_discrete</code> functions evaluate each variable's goodness of fit for the DAGs produced by the <code>bnlearn</code> package. The <code>evaluate_fit_continuous</code> evaluate continious variables and the <code>evaluate_fit_discrete</code> evaluates  discrete variables.</p>

<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>evaluate_fit_continuous(data, pred)
</span></code></pre>

<h4>Parameters</h4>
<p>The <code>evaluate_fit_continuous</code> function accepts the following parameters:</p>
<ul>
  <li><code>data</code>: a data frame containing continuous variables in the model</li>
  <li><code>pred</code>: a data frame containing continuous variables' predictions using the model</li>
</ul>
<hr style="border-top: 1px solid #ddd;">

<div class="snippet-clipboard-content notranslate position-relative overflow-auto"><pre class="notranslate"><code>evaluate_fit_discrete(data, pred)</span>
</code></pre>

<h4>Parameters</h4>
<p>The <code>evaluate_fit_discrete</code> function accepts the following parameters:</p>
<ul>
  <li><code>data</code>: a data frame containing discrete variables in the model</li>
  <li><code>pred</code>: a data frame containing discrete variables' predictions using the model</li>
</ul>


<h1 tabindex="-1" id="citations" dir="auto">Citations</h1>
When using this code or the associated manuscript, please cite using the following <a rel="bib" href="citation.bib"> citation.bib</a>.


<h1 tabindex="-1" id="Copyrights" dir="auto">Copyrights<svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></h1>

</article>
          </div>


This work is licensed under a Creative Commons Attribution 4.0 International License</a>. </br>[<img alt="Static Badge" src="https://img.shields.io/badge/license-CC--BY--4.0-tst">](https://creativecommons.org/licenses/by/4.0/) 
<h1 tabindex="-1" id="citations" dir="auto">References</h1>
  [1] M. Scutari. Learning Bayesian Networks with the bnlearn R Package. 
  Journal of Statistical Software, 35(3):1-22, 2010.
<a href="https://github.com/erdogant/bnlearn" target="_blank">
  <img alt="Static Badge" src="https://img.shields.io/badge/repo-bnlearn-black">
</a>

