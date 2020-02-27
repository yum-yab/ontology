createDirectories() {

	mkdir -p $repoPomDir/data/ontology/dbo-snapshots/$fullVersion
	cp $repoPomDir/pom.xml $repoPomDir/data/ontology/pom.xml
	cp $repoPomDir/dbo-snapshots/pom.xml $repoPomDir/data/ontology/dbo-snapshots/pom.xml
	cp $repoPomDir/dbo-snapshots/dbo-snapshots.md $repoPomDir/data/ontology/dbo-snapshots/dbo-snapshots.md
}

commitAndRelease() {
	
	
	cd $dataPomDir

	# Handling the git process
	echo "Commiting the data to git"
	git add --all
	git commit -m "$data_commit_info"
	git push

	# Releasing the new Version to maven
	file_commit=$(git rev-parse HEAD)
	echo "Commit-Hash of the files: ${file_commit}"

	# Generates commit-Message for the dataId-Release
	dataId_commit_info="Upload dataid.ttl for version: ${fullVersion}"
	
	
	# generates the dataid.ttl for the right version
	mvn versions:set -DnewVersion=${fullVersion}   
	mvn package -DfileHash=$file_commit

	# Copying the new dataId into the git
	cp dbo-snapshots/target/databus/$fullVersion/dataid.ttl $repoPomDir/dbo-snapshots/dataid.ttl
	
	# Commiting the new dataId to github
	echo "Commitig DataId to Git..."
	git add --all
	git commit -m "$dataId_commit_info"
	git push
	
	# deploy the data to the databus
	dataId_commit=$(git rev-parse HEAD)
	echo "DataId Hash: $dataId_commit"
	
	mvn databus:deploy -DfileHash=$file_commit -DdataIdHash=$dataId_commit
}

######################## BEGIN ##################################################

dataPomDir=$1
fullVersion=$(date "+%Y.%m.%d-%H%M%S")
