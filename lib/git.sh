
_load.load_once git && return 0

function git.push() {
    local project=$1
    local origin=$2
    local branch=$3

    pushd $project > /dev/null
    git push $origin $branch
    popd > /dev/null
}

function git.commit() {
    local project=$1
    local message=$2

    pushd $project > /dev/null
    git commit -m "$message"
    popd > /dev/null
}

function git.add_file() {
    local project=$1
    local file=$2

    pushd $project > /dev/null
    git add $file
    popd > /dev/null
}

function git.get_revision_from_project() {
    local projectUrl=$1
    local project=$2
    local origin=$3
    local branch=$4

    git.clone_in_folder $projectUrl $origin $project

    git.update_project $project $origin $branch
    utils.error_and_exit "Cannot update project $project"
    git.get_last_revision $project $origin $branch
    utils.error_and_exit "Error getting last revision: $project $branch"

    local revision=$_r
    _r=$revision
}


function git.get_last_revision() {
    local project=$1
    local origin=$2
    local branch=$3

    pushd $project > /dev/null
    
    local revision=$(git rev-parse $origin/$branch)
    _r=$revision
    if [ $? -ne 0 ]; then
        log.error "Error actualizando la rama $branch. Proceso detenido"
        popd > /dev/null
        return 1
    fi

    popd > /dev/null

}


function git.update_project() {
    local project=$1
    local origin=$2
    local branch=$3

    pushd $project > /dev/null

    git fetch $origin $branch
    if [ $? -ne 0 ]; then
        log.error "Error fetching project $project"
        popd > /dev/null
        return 1
    fi

    popd > /dev/null
}


function git.clone_in_folder() {
    local projectUrl=$1
    local origin=$2
    local folder=$3

    if [ ! -d "$folder" ]; then
        git clone --origin $origin $projectUrl $folder
        if [ $? -ne 0 ]; then
            log.error "Error clonning projct $projectUrl. Proceso detenido"
            return 1
        fi

    else
        if [ ! -d "$folder/.git" ]; then
            log.error "Folder provided is a folder already exists: $folder"
            return 1
        fi
    fi
}

