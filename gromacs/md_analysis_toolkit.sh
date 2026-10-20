#1
gro_center()
{
    read -p "Enter name of TPR file (-s) with '.tpr' md_0_100.tpr : " tpr
    echo
    read -p "Enter name of input XTC file (-f) with '.xtc' md_0_100.xtc : " xtc_in
    echo
    read -p "Enter name of output XTC file (-o) with '.xtc' md_0_100_center.xtc : " xtc_out
    echo
    echo 1 0 | gmx trjconv -s "$tpr" -f "$xtc_in" -o "$xtc_out" -center -pbc mol -ur compact
    echo
    echo "✅ PBC Centering done. Output written to $xtc_out"
}

#2
gro_fit()
{
    read -p "Enter name of TPR file (-s) with '.tpr' md_0_100.tpr : " tpr
    echo
    read -p "Enter name of centered XTC file (-f) with '.xtc' md_0_100_center.xtc : " xtc_in
    echo
    read -p "Enter name of output XTC file (-o) with '.xtc' md_0_100_fit.xtc : " xtc_out
    echo
    echo 4 0 | gmx trjconv -s "$tpr" -f "$xtc_in" -o "$xtc_out" -fit rot+trans
    echo
    echo "✅ PBC Fitting done. Output written to $xtc_out"
}   

#3
gro_rmsd() {
    echo
    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
    echo
    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
    echo
    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
    echo
    read -p "Do you want RMSD for protein or ligand? (pro/lig): " choice
    echo

    case "$choice" in
        pro)
            read -p "Enter fitting group number for Protein (e.g., 4): " fit_group
            read -p "Enter RMSD calculation group number for Protein (e.g., 4): " calc_group
            echo
            out="rmsd_pro.xvg"
            echo "$fit_group $calc_group" | gmx rms -s "$tpr" -f "$xtc_in" -n "$ndx_in" -tu ns -o "$out"
            ;;
        lig)
            read -p "Enter fitting group number (usually Protein, e.g., 4): " fit_group
            read -p "Enter RMSD calculation group number for Ligand (e.g., 13): " calc_group
            echo
            out="rmsd_lig.xvg"
            echo "$fit_group $calc_group" | gmx rms -s "$tpr" -f "$xtc_in" -n "$ndx_in" -tu ns -o "$out"
            ;;
        *)
            echo "❌ Invalid choice. Please type 'pro' or 'lig'."
            return 1
            ;;
    esac

    echo
    echo "✅ RMSD calculation done."
    echo "📄 Output file: $out"
}

##gro_rmsd()
##{
##    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
##    echo
##    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
##    echo
##    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
##    echo
##    read -p "Do you want RMSD for protein or ligand? (pro/lig): " choice
##    echo
##
##    case "$choice" in
##        pro)
##            out="rmsd_pro.xvg"
##            echo "4 4" | gmx rms -s "$tpr" -f "$xtc_in" -n "$ndx_in" -tu ns -o "$out"
##            ;;
##        lig)
##            out="rmsd_lig.xvg"
##            echo "4 13" | gmx rms -s "$tpr" -f "$xtc_in" -n "$ndx_in" -tu ns -o "$out"
##            ;;
##        *)
##            echo "❌ Invalid choice. Please type 'pro' or 'lig'."
##            return 1
##            ;;
##    esac
##}

#4
gro_rmsf() {
    echo
    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
    echo
    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
    echo
    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
    echo
    read -p "Do you want RMSF for protein or ligand? (pro/lig): " choice
    echo

    case "$choice" in
        pro)
            read -p "Enter group number for Protein (e.g., 4): " pro_group
            echo
            out="rmsf_pro.xvg"
            echo "$pro_group" | gmx rmsf -s "$tpr" -f "$xtc_in" -o "$out" -res -n "$ndx_in"
            ;;
        lig)
            read -p "Enter group number for Ligand (e.g., 23): " lig_group
            echo
            out="rmsf_lig.xvg"
            echo "$lig_group" | gmx rmsf -s "$tpr" -f "$xtc_in" -o "$out" -n "$ndx_in"
            ;;
        *)
            echo "❌ Invalid choice. Please type 'pro' or 'lig'."
            return 1
            ;;
    esac

    echo
    echo "✅ RMSF calculation done."
    echo "📄 Output file: $out"
}

##gro_rmsf() {
##    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
##    echo
##    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
##    echo
##    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
##    echo
##    read -p "Do you want RMSF for protein or ligand? (pro/lig): " choice
##    echo
##
##    case "$choice" in
##        pro)
##            out="rmsf_pro.xvg"
##            echo "4" | gmx rmsf -s "$tpr" -f "$xtc_in" -o "$out" -res -n "$ndx_in"
##            ;;
##        lig)
##            out="rmsf_lig.xvg"
##            echo "23" | gmx rmsf -s "$tpr" -f "$xtc_in" -o "$out" -n "$ndx_in"
##            ;;
##        *)
##            echo "❌ Invalid choice. Please type 'pro' or 'lig'."
##            return 1
##            ;;
##    esac
##    echo "✅ RMSF calculation done. Output written to $out"
##}

#5
gro_ligHev_ndx()  
{
    read -p "Enter GRO file (e.g., em.gro): " gro
    echo
    read -p "Enter existing index file (e.g., index.ndx): " ndx
    echo

    gmx make_ndx -f "$gro" -n "$ndx" << EOF
13 & ! a H*
q
EOF
    echo
    echo "✅ Ligand Heavy Atom's index groups included to index.ndx"
}

#6
gro_rg()
{
    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
    echo
    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
    echo
    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
    echo
    read -p "Enter donor and acceptor group numbers (e.g., '1 13'): " groups
    echo

    out="rg_pro.xvg"
    echo "$groups" | gmx gyrate -s "$tpr" -f "$xtc_in" -o "$out" -n "$ndx_in"
    echo
    echo "✅ Rg calculation done. Output written to $out"
}

#7
gro_hbond()
{
    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
    echo
    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
    echo
    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
    echo
    read -p "Enter donor and acceptor group numbers (e.g., '1 13'): " groups
    echo

    out="hbond.xvg"
    echo "$groups" | gmx hbond -s "$tpr" -f "$xtc_in" -n "$ndx_in" -num "$out"
    echo
    echo "✅ Hydrogen Bond analysis done. Output written to $out"
}

#8
gro_MinDist()
{
    read -p "Enter name of TPR file (-s) with '.tpr' (e.g., em.tpr): " tpr
    echo
    read -p "Enter name of input XTC file (-f) with '.xtc' (e.g., md_0_100_center.xtc): " xtc_in
    echo
    read -p "Enter name of index file (-n) with '.ndx' (e.g., pro_lig/pep.ndx): " ndx_in
    echo
    read -p "Enter donor and acceptor group numbers (e.g., '1 13'): " groups
    echo

    out="min_dist_pro_lig.xvg"
    echo "$groups" | gmx mindist -s "$tpr" -f "$xtc_in" -n "$ndx_in" -od "$out"

    echo "✅ Minimum Distance between Protein & Ligand is written to $out"
}

#9
#8
gro_cluster()
{
    echo
    read -p "Enter CENTERED XTC file (-f) (e.g., md_0_100_center.xtc): " xtc_in
    echo
    read -p "Enter PROD TPR file (-s) (e.g., md_0_100.tpr): " tpr
    echo

    read -p "Enter START time in ps (-b) (e.g., 20000): " btime
    echo
    #read -p "Enter END time in ps (-e) [press Enter to skip]: " etime
    #echo

    echo "Choose time step (-dt):"
    echo "  1) 10 ps"
    echo "  2) 100 ps"
    echo "  3) Custom"
    read -p "Select option (1/2/3): " dt_choice

    case "$dt_choice" in
        1) dt=10 ;;
        2) dt=100 ;;
        3)
            read -p "Enter custom dt value (ps): " dt
            ;;
        *)
            echo "❌ Invalid choice. Using default dt = 10 ps"
            dt=10
            ;;
    esac
    echo

    read -p "Enter index file (-n) [default: index.ndx]: " ndx
    ndx=${ndx:-index.ndx}
    echo

    # ---------- Build command safely ----------
    cmd="gmx cluster \
        -f $xtc_in \
        -s $tpr \
        -method gromos \
        -cutoff 0.15 \
        -b $btime \
        -dt $dt \
        -n $ndx \
        -g -cl"
        #-g -cl -e"

    # Only add -e if user provided it
    if [[ -n "$etime" ]]; then
        cmd="$cmd -e $etime"
    fi

    echo "▶ Running command:"
    echo "$cmd"
    echo

    eval $cmd

    echo
    echo "✅ Clustering completed successfully."
}

#10
gro_pca()
{
    echo
    read -p "Enter STRUCTURE file (.gro or .tpr): " str
    read -p "Enter CENTERED XTC file: " xtc
    echo
    
    read -p "Enter index file (-n) [default: index.ndx]: " ndx
    ndx=${ndx:-index.ndx}
    echo
    
    # ---- Covariance analysis ----
    echo 2 2 | gmx covar \
        -s "$str" \
        -f "$xtc" \
        -o eigenvalues.xvg \
        -v eigenvectors.trr \
        -xpma covar.xpm \
        -n "$ndx"
    
    # ---- Projections onto PCs (MANUAL, HARD-CODED) ----
    echo 3 3 | gmx anaeig -f "$xtc" -s "$str" -v eigenvectors.trr -first 1 -last 1 -proj pc1.xvg -n "$ndx"
    echo 3 3 | gmx anaeig -f "$xtc" -s "$str" -v eigenvectors.trr -first 2 -last 2 -proj pc2.xvg -n "$ndx"
    echo 3 3 | gmx anaeig -f "$xtc" -s "$str" -v eigenvectors.trr -first 3 -last 3 -proj pc3.xvg -n "$ndx"
    echo 3 3 | gmx anaeig -f "$xtc" -s "$str" -v eigenvectors.trr -first 4 -last 4 -proj pc4.xvg -n "$ndx"
    echo 3 3 | gmx anaeig -f "$xtc" -s "$str" -v eigenvectors.trr -first 5 -last 5 -proj pc5.xvg -n "$ndx"
    
    # ---- Cosine content ----
    gmx analyze -f pc1.xvg -cc pc1_cosine.xvg >  cosine_data.txt
    gmx analyze -f pc2.xvg -cc pc2_cosine.xvg >> cosine_data.txt
    gmx analyze -f pc3.xvg -cc pc3_cosine.xvg >> cosine_data.txt
    gmx analyze -f pc4.xvg -cc pc4_cosine.xvg >> cosine_data.txt
    gmx analyze -f pc5.xvg -cc pc5_cosine.xvg >> cosine_data.txt
    
    # ---- Clean PC files ----
    awk '!/^[@#]/ {print NR-1, $2}' pc1.xvg > pc1_clean.txt
    awk '!/^[@#]/ {print NR-1, $2}' pc2.xvg > pc2_clean.txt
    awk '!/^[@#]/ {print NR-1, $2}' pc3.xvg > pc3_clean.txt
    awk '!/^[@#]/ {print NR-1, $2}' pc4.xvg > pc4_clean.txt
    awk '!/^[@#]/ {print NR-1, $2}' pc5.xvg > pc5_clean.txt

    echo
    echo "✅ PCA analysis completed correctly."
}

#11
gro_fel()
{
    echo
    echo "###############################################"
    echo "#     Interactive Free Energy Landscape        #"
    echo "###############################################"
    echo

    read -p "Enter first PC file (e.g. pc1_clean.txt): " pcfile1
    read -p "Enter second PC file (e.g. pc2_clean.txt): " pcfile2
    echo

    read -p "Enter name for first PC axis (e.g. PC1): " pcname1
    read -p "Enter name for second PC axis (e.g. PC2): " pcname2
    echo

    read -p "Enter energy value (e.g. 2.0): " energy
    read -p "Enter discretization value (e.g. 1.0): " discret
    echo

    echo "▶ Generating Free Energy Landscape..."
    echo

    free_energy_landscape "$pcfile1" "$pcfile2" \
        --names "$pcname1" "$pcname2" \
        --energy "$energy" \
        --discretize "$discret"

    echo
    echo "✅ Free Energy Landscape generation completed."
}

#12
gro_frss()
{
    echo
    read -p "Enter trajectory file (XTC): " XTC
    read -p "Enter structure/topology file (TPR): " TPR
    echo

    read -p "Enter index group number to extract (e.g. 3): " GROUP
    echo

    read -p "Enter time per frame dt (ps) (e.g. 10): " dt
    echo

    read -p "Enter frame numbers (space-separated, e.g. 4877 4862 4764): " frames
    echo

    for f in $frames; do
        time_ps=$(( f * dt ))
        echo "Extracting frame $f  →  time ${time_ps} ps"

        echo "$GROUP" | gmx trjconv \
            -f "$XTC" \
            -s "$TPR" \
            -dump "$time_ps" \
            -o "ss_frame_${f}.pdb"
    done
}

